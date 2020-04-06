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
    private var stopwatch = Stopwatch()
    private var suggestions = ExcerciseUserSuggestions()

    @State private var location: Location? = nil
    @State private var workoutDataTaskPublisher: AnyCancellable? = nil
    @State private var userEntryCancellable: AnyCancellable? = nil
    @State private var newEntryTextField: UITextField? = nil
    @State private var workoutNameTextField: UITextField? = nil

    @State private var newEntryState: EditableExerciseState = EditableExerciseState(input: "")

    init() {
        stopwatch.start()
    }

    func pressPause() {
        #if targetEnvironment(simulator)
        self.location = Location(latitude: 37.34727983131215, longitude: -121.88308869874288)
        #else
        let coord: CLLocationCoordinate2D? = locationManager.lastLocation?.coordinate
        self.location = coord != nil ? Location(latitude: coord!.latitude, longitude: coord!.longitude) : nil
        #endif

        self.stopwatch.stop()
        self.state.isStopped = true
    }
    
    func pressResume() {
        self.stopwatch.start()
        self.state.isStopped = false
    }
    
    func pressFinish() {
        let exercises: [Exercise] = state.activities.map{ a in Exercise(raw: a.input) }
        let name = state.workoutName.isEmpty ? dateToWorkoutName(self.state.date) : state.workoutName

        let workout = Workout(
            name: name,
            date: self.state.date,
            exercises: exercises,
            location: self.location,
            secondsElapsed: stopwatch.counter
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
            if state.isStopped {
                VStack(alignment: .center) {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            self.pressResume()
                        }) {
                            Text("Resume")
                                .font(.caption)
                                .foregroundColor(Color.white)
                                .background(GeometryReader { (geometry: GeometryProxy) in
                                    RoundedRectangle(cornerRadius: 6)
                                        .size(
                                            width: geometry.size.width + 10,
                                            height: geometry.size.height + 10
                                        )
                                        .offset(x: -5, y: -5)
                                        .fill(appColor)
                                })
                        }
                            .padding(.trailing)
                    }
                    Divider()
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
                            
                            TextField(dateToWorkoutName(self.state.date), text: $state.workoutName, onCommit: {
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
                        }
                    }

                    EditableWorkoutDetailCardView(
                        stopwatch: stopwatch,
                        stretchToFillParent: !state.isStopped,
                        showDate: state.isStopped,
                        showExercises: !state.isStopped
                    )
                        .fixedSize(horizontal: state.isStopped, vertical: true)
                        .padding(state.isStopped ? [.leading] : [.top, .trailing, .leading])
                        .padding(.bottom, state.isStopped ? 5 : 20)

                    if state.isStopped {
                        if self.location != nil {
                            MapView(location: self.location!)
                                .frame(height: 130)
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
                        self.pressPause()
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
                        self.pressFinish()
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
            .modifier(AdaptsToSoftwareKeyboard())
    }
}

public struct DividerSpacer: View {
    public var body: some View {
        return HStack(spacing: 0) {
            Spacer()
            Divider()
            Spacer()
        }
    }
}

public struct EditableWorkoutDetailCardView: View {
    @EnvironmentObject var state: EditableWorkoutState
    @ObservedObject var stopwatch: Stopwatch
    var stretchToFillParent = true
    var showDate = true
    var showTime = true
    var showExercises = true
    var showDistance = true
    var showWeight = true
    
    public var body: some View {
        HStack(spacing: stretchToFillParent ? 0 : 10) {
            if showDate {
                WorkoutDetail(
                    name: self.state.date.abbreviatedMonthString,
                    value: self.state.date.dayString
                )
            }
            
            if showDate && (showTime || showWeight || showDistance || showExercises) {
                if stretchToFillParent {
                    DividerSpacer()
                } else {
                    Divider()
                }
            }
            
            if showTime {
                WorkoutDetail(
                    name: "Time",
                    value: secondsToElapsedTimeString(stopwatch.counter)
                )
                    .frame(width: 70, alignment: .leading)
                    .fixedSize()
            }
            
            if showTime && (showWeight || showDistance || showExercises) {
                if stretchToFillParent {
                    DividerSpacer()
                } else {
                    Divider()
                }
            }

            if showWeight {
                WorkoutDetail(
                    name: "Weight",
                    value:"45000 lbs"
                )
            }
            
            if showWeight && (showDistance || showExercises) {
                if stretchToFillParent {
                    DividerSpacer()
                } else {
                    Divider()
                }
            }

            if showDistance {
                WorkoutDetail(
                    name: "Distance",
                    value: "14 km"
                )
            }
            
            if showDistance && showExercises {
                if stretchToFillParent {
                    DividerSpacer()
                } else {
                    Divider()
                }
            }
            
            if showExercises {
                WorkoutDetail(
                    name: "Exercises",
                    value: "\(state.activities.count)"
                )
            }
        }
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
