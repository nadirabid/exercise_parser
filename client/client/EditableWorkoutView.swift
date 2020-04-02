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

public struct EditableWorkoutView: View {
    @EnvironmentObject var route: RouteState
    @EnvironmentObject var state: EditableWorkoutState
    @EnvironmentObject var workoutAPI: WorkoutAPI
    
    @ObservedObject private var locationManager = LocationManager()
    private var stopWatch = Stopwatch()
    private var suggestions = ExcerciseUserSuggestions()
    
    @State private var location: Location? = nil
    @State private var workoutDataTaskPublisher: AnyCancellable? = nil
    @State private var userEntryCancellable: AnyCancellable? = nil
    @State private var newEntryTextField: UITextField? = nil
    @State private var workoutNameTextField: UITextField? = nil
    
    @State private var newEntryState: EditableExerciseState = EditableExerciseState(input: "")

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
        let exercises: [Exercise] = state.activities.map{ a in Exercise(raw: a.input) }
        let name = state.workoutName.isEmpty ? dateToWorkoutName(date) : state.workoutName
        
        let workout = Workout(
            name: name,
            date: self.date,
            exercises: exercises,
            location: self.location,
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
        VStack(alignment: .leading) {
            if !state.isStopped {
                TimerView(stopWatch: stopWatch)
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
                            EditableExerciseView(
                                state: activity,
                                suggestions: self.suggestions,
                                onUserInputCommit: { _ in
                                    DispatchQueue.main.async {
                                        self.newEntryTextField?.becomeFirstResponder()
                                    }
                                }
                            )
                        }
                    }
                        .background(Color.white)

                    if !state.isStopped {
                        EditableExerciseView(
                            state: newEntryState,
                            isNewEntry: true,
                            suggestions: suggestions,
                            onUserInputCommit: { (textField: UITextField) in
                                if !self.newEntryState.input.isEmpty {
                                    self.state.activities.append(self.newEntryState)
                                    self.newEntryState = EditableExerciseState(input: "")
                                }
                                
                                DispatchQueue.main.async {
                                    textField.becomeFirstResponder()
                                }
                            },
                            onTextFieldChange: { (textField: UITextField) in
                                self.newEntryTextField = textField
                            }
                        )
                    }
                }
            }

            Spacer()
            
            HStack(spacing: 0) {
                if !state.isStopped {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            self.pressPause()
                        }
                    }) {
                        HStack {
                            Spacer()
                            
                            Text("Pause")
                                .foregroundColor(Color.white)
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                            .padding()
                            .background(appColor)
                    }
                }
                else {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            self.pressFinish()
                        }
                    }) {
                        HStack {
                            Spacer()
                            
                            Text(state.activities.count > 0 ? "Finish" : "Cancel")
                                .foregroundColor(Color.white)
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                            .padding()
                            .background(appColor)
                    }
                }
            }
        }.modifier(AdaptsToSoftwareKeyboard())
    }
}

#if DEBUG
struct WorkoutEditorView_Previews : PreviewProvider {
    static var previews: some View {
        let workoutEditorState = EditableWorkoutState()
        workoutEditorState.activities = []
        
        return EditableWorkoutView()
            .environmentObject(workoutEditorState)
            .environmentObject(RouteState(current: .editor))
            .environmentObject(MockWorkoutAPI(userState: UserState()) as WorkoutAPI)
            .environmentObject(MockExerciseAPI(userState: UserState()) as ExerciseAPI)
    }
}
#endif
