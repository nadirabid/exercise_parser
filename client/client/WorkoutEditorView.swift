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

class ExerciseDefaultEntries: ObservableObject {
    @Published var current: Exercise? = nil
    @Published var index = 4
    private var timer: Timer? = nil
    private var options = [
        Exercise(
            name: "Tricep curls",
            type: ExerciseType.weighted.rawValue,
            raw: "3x3 tricep curls",
            weightedExercise: WeightedExercise(sets: 3, reps: 3)
        ),
        Exercise(
            name: "Running",
            type: ExerciseType.distance.rawValue,
            raw: "ran 3.3 miles in 7 mins",
            distanceExercise: DistanceExercise(time: "7", distance: 3.3, units: "miles")
        ),
        Exercise(
            name: "Rowing",
            type: ExerciseType.distance.rawValue,
            raw: "rowing 4km in 16 mins",
            distanceExercise: DistanceExercise(time: "16", distance: 5, units: "km")
        ),
        Exercise(
            name: "Bench press",
            type: ExerciseType.weighted.rawValue,
            raw: "bench press 3x3x3",
            weightedExercise: WeightedExercise(sets: 3, reps: 3)
        )
    ]
    
    init() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
            self.index = (self.index + 1) % (self.options.count + 2)
            
            withAnimation(Animation.easeInOut.speed(2)) {
                if self.index < self.options.count {
                    self.current = self.options[self.index]
                } else {
                    self.current = nil
                }
            }
        }
    }
    
    func reset() {
        self.index = self.options.count
        self.current = nil
    }
    
    func stop() {
        self.timer?.invalidate()
    }
}

public struct WorkoutEditorView: View {
    @EnvironmentObject var route: RouteState
    @EnvironmentObject var state: WorkoutEditorState
    @EnvironmentObject var workoutAPI: WorkoutAPI
    
    @ObservedObject private var stopWatch = Stopwatch()
    @ObservedObject private var locationManager = LocationManager()
    @ObservedObject private var defaultEnteries = ExerciseDefaultEntries()
    
    @State private var location: Location? = nil
    @State private var workoutDataTaskPublisher: AnyCancellable? = nil
    @State private var userEntryCancellable: AnyCancellable? = nil
    @State private var newEntryTextField: UITextField? = nil
    @State private var workoutNameTextField: UITextField? = nil

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
                                onTextFieldCommit: {
                                    self.newEntryTextField?.becomeFirstResponder()
                                }
                            )
                        }
                    }
                        .background(Color.white)
                    
                    if !state.isStopped {
                        TextField(
                            self.defaultEnteries.current?.raw ?? "Enter exercise",
                            text: $state.newEntry,
                            onCommit: {
                                self.state.newEntry = self.state.newEntry.trimmingCharacters(in: .whitespaces)
                                
                                if !self.state.newEntry.isEmpty {
                                    let userActivity = UserActivity(input: self.state.newEntry)
                                    self.state.activities.append(userActivity)
                                    
                                    self.state.newEntry = ""
                                    self.newEntryTextField = nil
                                }
                            }
                        )
                            .introspectTextField { (textField: UITextField) in
                                if self.newEntryTextField != textField {
                                    textField.autocorrectionType = UITextAutocorrectionType.no
                                    textField.returnKeyType = .next
                                    textField.becomeFirstResponder()
                                    
                                    self.userEntryCancellable = self.state.$newEntry.sink { (value) in
                                        if value.isEmpty {
                                            self.defaultEnteries.reset()
                                        }
                                    }
                                }
                                self.newEntryTextField = textField
                            }
                            .padding([.leading, .trailing])
                        
                        if defaultEnteries.current != nil && state.newEntry.isEmpty {
                            ExerciseView(exercise: defaultEnteries.current!, asSecondary: true)
                                .padding([.leading, .trailing])
                                .transition(AnyTransition.moveUpAndFade())
                                .id("default_enteries_\(defaultEnteries.current!.raw)") // unique ID forces transition
                        } else {
                            WaitingForExerciseView()
                                .padding([.leading, .trailing])
                                .transition(AnyTransition.moveUpAndFade())
                        }
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
        }
        
        return view.modifier(AdaptsToSoftwareKeyboard())
    }
}

#if DEBUG
struct WorkoutEditorView_Previews : PreviewProvider {
    static var previews: some View {
        let workoutEditorState = WorkoutEditorState()
        workoutEditorState.activities = [
//            UserActivity(input: "3x3 tricep curls"),
//            UserActivity(input: "4 mins of running"),
//            UserActivity(input: "benchpress 3x3x2", dataTaskPublisher: nil, exercise: Exercise(type: "unknown"))
        ]
        
        return WorkoutEditorView()
            .environmentObject(workoutEditorState)
            .environmentObject(RouteState(current: .editor))
            .environmentObject(MockWorkoutAPI(userState: UserState()) as WorkoutAPI)
            .environmentObject(MockExerciseAPI(userState: UserState()) as ExerciseAPI)
    }
}
#endif
