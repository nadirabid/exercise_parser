//
//  WorkoutEditorView.swift
//  client
//
//  Created by Nadir Muzaffar on 10/12/19.
//  Copyright © 2019 Nadir Muzaffar. All rights reserved.
//

import SwiftUI
import Introspect
import Combine
import Alamofire
import MapKit
import UIKit

struct ScaleEffectHeightModifier: ViewModifier {
    let height: CGFloat

    init(_ height: CGFloat) {
        self.height = height
    }

    func body(content: Content) -> some View {
        content.scaleEffect(x: 1, y: height, anchor: UnitPoint.top)
    }
}

extension AnyTransition {
    static func scaleHeight(from: CGFloat, to: CGFloat) -> AnyTransition {
        .modifier(
            active: ScaleEffectHeightModifier(from),
            identity: ScaleEffectHeightModifier(to)
        )
    }
}

struct AdaptsToSoftwareKeyboard: ViewModifier {
    @State var currentHeight: CGFloat = 0
    @State var isKeyboardDisplayed = false
    
    @State private var showKeyBoardCancellable: AnyCancellable? = nil
    @State private var hideKeyBoardCancellable: AnyCancellable? = nil
    
    func body(content: Content) -> some View {
        return content
            .padding(.bottom, currentHeight)
            .edgesIgnoringSafeArea(isKeyboardDisplayed ? [.bottom] : [])
            .onAppear(perform: subscribeToKeyboardEvents)
    }
    
    private func subscribeToKeyboardEvents() {
        let speed = 2.2
        
        self.showKeyBoardCancellable = NotificationCenter.Publisher(
            center: NotificationCenter.default,
            name: UIResponder.keyboardWillShowNotification
        ).compactMap { notification in
            notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect
        }.map { rect in
            rect.height
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: { (height) in
            self.isKeyboardDisplayed = true
            
            withAnimation(Animation.easeInOut.speed(speed)) {
                self.currentHeight = height
            }
        })
        
        self.hideKeyBoardCancellable = NotificationCenter.Publisher(
            center: NotificationCenter.default,
            name: UIResponder.keyboardWillHideNotification
        ).compactMap { notification in
            CGFloat.zero
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: { (height) in
            self.isKeyboardDisplayed = false
            
            withAnimation(Animation.easeInOut.speed(speed)) {
                self.currentHeight = height
            }
        })
    }
}

public struct WorkoutEditorView: View {
    @EnvironmentObject var route: RouteState
    @EnvironmentObject var state: WorkoutEditorState
    @EnvironmentObject var workoutAPI: WorkoutAPI
    
    @ObservedObject private var stopWatch: Stopwatch = Stopwatch()
    @ObservedObject private var locationManager: LocationManager = LocationManager()
    
    @State private var workoutDataTaskPublisher: AnyCancellable? = nil
    @State private var newEntryTextField: UITextField? = nil
    @State private var workoutNameTextField: UITextField? = nil
    @State private var location: Location? = nil
    
    private var date: Date = Date()
    
    init() {
        stopWatch.start()
    }
    
    func pressPause() {
        #if targetEnvironment(simulator)
        self.location = Location(latitude: 37.34727983131215, longitude: -121.88308869874288)
        #else
        let coord: CLLocationCoordinate2D? = locationManager.lastLocation?.coordinate
        self.location = coord != nil ? Location(latitude: coord!.latitude, longitude: coord!.longitude) : nil
        #endif
        
        self.stopWatch.stop()
        self.state.isStopped = true
    }
    
    func pressResume() {
        self.stopWatch.start()
        self.state.isStopped = false
    }
    
    func pressFinish() {
        let coord: CLLocationCoordinate2D? = locationManager.lastLocation?.coordinate
        let location = coord != nil ? Location(latitude: coord!.latitude, longitude: coord!.longitude) : nil
        let exercises: [Exercise] = state.activities.map{ a in Exercise(raw: a.input) }
        let workout = Workout(
            name: state.workoutName,
            date: self.date,
            exercises: exercises,
            location: location,
            secondsElapsed: stopWatch.counter
        )
        
        if exercises.count == 0 {
            self.state.reset()
            self.route.current = .feed
            return
        }
        
        workoutAPI.createWorkout(workout: workout) { (_) in
            self.state.reset()
            self.route.current = .feed
        }
    }
    
    public var body: some View {
        let view = VStack(alignment: .leading) {
            if !state.isStopped {
                HStack {
                    Spacer()
                    
                    Text(self.stopWatch.convertCountToTimeString())
                        .font(.title)
                        .allowsTightening(true)
                    
                    Spacer()
                }
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if state.isStopped {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Workout name")
                                .font(.caption)
                                .padding([.leading, .top])
                                .padding(.bottom, 3)
                                .foregroundColor(Color.gray)
                            
                            TextField(dateToWorkoutName(date), text: $state.workoutName, onCommit: {
                                self.state.workoutName = self.state.workoutName.trimmingCharacters(in: .whitespaces)
                            })
                                .padding([.leading, .trailing])
                                .padding([.top, .bottom], 12)
                                .background(Color(#colorLiteral(red: 0.9813412119, green: 0.9813412119, blue: 0.9813412119, alpha: 1)))
                                .border(Color(#colorLiteral(red: 0.9160850254, green: 0.9160850254, blue: 0.9160850254, alpha: 1)))
                                .introspectTextField { textField in
                                    if self.workoutNameTextField ==  nil { // only become first responder the first time
                                        textField.becomeFirstResponder()
                                    }
                                    self.workoutNameTextField = textField
                                }
                            
                            Text("Breakdown")
                                .font(.caption)
                                .padding([.leading, .top])
                                .padding(.bottom, 3)
                                .foregroundColor(Color.gray)
                        
                            HStack(spacing: 10) {
                                WorkoutDetail(
                                    name: date.abbreviatedMonthString,
                                    value: date.dayString
                                )
                                Divider()

                                WorkoutDetail(name: "Time", value: secondsToElapsedTimeString(stopWatch.counter))
                                Divider()

                                WorkoutDetail(name: "Exercises", value: "\(state.activities.count)")
                                Divider()

                                WorkoutDetail(name: "Weight", value:"45000 lbs")
                            }
                                .fixedSize(horizontal: true, vertical: true)
                                .padding(.leading)
                                .padding(.bottom, 5)
                            
                            if self.location != nil {
                                MapView(location: self.location!)
                                    .frame(height: 130)
                                    .transition(
                                        AnyTransition
                                            .scaleHeight(from: 0, to: 1)
                                            .combined(with: AnyTransition.opacity)
                                    )
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Exercises")
                                .font(.caption)
                                .padding([.leading, .top])
                                .padding(.bottom, 3)
                                .foregroundColor(Color.gray)
                        }
                    }
                    
                    VStack(spacing: 0) {
                        ForEach(state.activities, id: \.id) { activity in
                            ExerciseEditorView(
                                activity: activity,
                                textFieldContext: self.newEntryTextField
                            )
                        }
                    }
                        .background(Color.white)
                    
                    if !state.isStopped {
                        TextField("New entry", text: $state.newEntry, onCommit: {
                            self.state.newEntry = self.state.newEntry.trimmingCharacters(in: .whitespaces)
                            
                            if !self.state.newEntry.isEmpty {
                                let userActivity = UserActivity(input: self.state.newEntry)
                                self.state.activities.append(userActivity)
                                
                                self.state.newEntry = ""
                                self.newEntryTextField = nil
                            }
                        })
                            .introspectTextField { textField in
                                if self.newEntryTextField == nil {
                                    textField.becomeFirstResponder()
                                }
                                self.newEntryTextField = textField
                            }
                            .padding([.leading, .trailing])
                    }
                }
            }

            Spacer()
            
            HStack(spacing: 0) {
                if !state.isStopped {
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            self.pressPause()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(appColor)
                                .shadow(color: Color.gray.opacity(0.3), radius: 1.0)
                                .frame(width: 70, height: 70)
                            
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .stroke(lineWidth: 2)
                                .fill(Color.white)
                                .frame(width: 14, height: 14)
                        }
                    }
                        .transition(
                            AnyTransition.opacity.animation(Animation.easeInOut(duration: 0.1))
                        )
                    
                    Spacer()
                }
                else {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            self.pressFinish()
                        }
                    }) {
                        HStack {
                            Spacer()
                            
                            Text("Finish")
                                .foregroundColor(Color.white)
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                            .padding()
                            .background(appColor)
                    }
                        .transition(
                            AnyTransition.opacity.animation(Animation.easeInOut(duration: 0.1))
                        )
                }
            }
        }
        
        return VStack(spacing: 0) {
            if state.isStopped {
                view.modifier(AdaptsToSoftwareKeyboard())
            } else {
                view
            }
        }
    }
}

#if DEBUG
struct WorkoutEditorView_Previews : PreviewProvider {
    static var previews: some View {
        let workoutEditorState = WorkoutEditorState()
        workoutEditorState.activities = [
            UserActivity(input: "3x3 tricep curls"),
            UserActivity(input: "4 mins of running"),
            UserActivity(input: "benchpress 3x3x2", dataTaskPublisher: nil, exercise: Exercise(type: "unknown"))
        ]
        workoutEditorState.isStopped = true
        
        return WorkoutEditorView()
            .environmentObject(workoutEditorState)
            .environmentObject(RouteState(current: .editor))
            .environmentObject(MockWorkoutAPI(userState: UserState()) as WorkoutAPI)
            .environmentObject(MockExerciseAPI(userState: UserState()) as ExerciseAPI)
    }
}
#endif
