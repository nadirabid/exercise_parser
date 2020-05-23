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
import Foundation

public struct WorkoutCreateView: View {
    @EnvironmentObject var route: RouteState
    @EnvironmentObject var state: WorkoutCreateState
    @EnvironmentObject var workoutAPI: WorkoutAPI

    private var locationManager = LocationManager()
    private var stopwatch = Stopwatch()
    private var suggestions = ExcerciseUserSuggestions()

    @State private var location: Location? = nil
    @State private var newEntryTextField: UITextField? = nil
    @State private var workoutNameTextField: UITextField? = nil
    @State private var newEntryState: ExerciseEditState = ExerciseEditState(input: "")

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
        let exercises: [Exercise] = state.exerciseStates.map{ a in Exercise(raw: a.input) }
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
            self.route.replaceCurrent(with: .userFeed)
            return
        }

        workoutAPI.createWorkout(workout: workout) { (_) in
            self.state.reset()
            self.route.replaceCurrent(with: .userFeed)
        }
    }
    
    func removeExerciseStateElement(state: ExerciseEditState) {
        self.state.exerciseStates.removeAll(where: { e in
            return e === state
        })
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if state.isStopped {
                VStack(alignment: .center) {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            withAnimation(Animation.easeInOut.speed(1.5)) {
                                self.pressResume()
                            }
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

            EditableWorkoutMetaMetricsView(
                stopwatch: stopwatch,
                showDate: state.isStopped
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
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(self.state.exerciseStates, id: \.id) { (exerciseState: ExerciseEditState) in
                        VStack(spacing: 0) {
                            ExerciseEditView(
                                state: exerciseState,
                                suggestions: self.suggestions,
                                onUserInputCommit: { _ in
                                    DispatchQueue.main.async {
                                        if exerciseState.input.isEmpty {
                                            self.state.exerciseStates.removeAll(where: { ex in
                                                return ex === exerciseState
                                            })
                                        }
                                        self.newEntryTextField?.becomeFirstResponder()
                                    }
                                }
                            )
                                .padding([.top, .bottom], 6)
                                .transition(AnyTransition.slide.combined(with: AnyTransition.scale))
                            
                            Divider().animation(Animation.easeInOut.speed(2))
                        }
                            .modifier(DeletableViewModifier(disable: self.state.isStopped, onClick: {
                                self.removeExerciseStateElement(state: exerciseState)
                            }))
                    }

                    if !self.state.isStopped {
                        VStack(spacing: 0) {
                            ExerciseEditView(
                                state: self.newEntryState,
                                isNewEntry: true,
                                suggestions: self.suggestions,
                                onUserInputCommit: { (textField: UITextField) in
                                    DispatchQueue.main.async {
                                        if !self.newEntryState.input.isEmpty {
                                            self.state.exerciseStates.append(self.newEntryState)
                                            self.newEntryState = ExerciseEditState(input: "")
                                        }
                                        textField.becomeFirstResponder()
                                    }
                                },
                                onTextFieldChange: { (textField: UITextField) in
                                    self.newEntryTextField = textField
                                }
                            )
                                .padding([.top, .bottom], 6)

                            Divider().animation(Animation.easeInOut.speed(2))
                        }
                    }
                }
            }
            
            Spacer()
            
            HStack(spacing: 0) {
                if !state.isStopped {
                    Button(action: {
                        withAnimation(Animation.easeInOut.speed(1.5)) {
                            self.pressPause()
                        }
                    }) {
                        HStack {
                            Spacer()
                            
                            Text("Stop")
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
                        withAnimation(Animation.easeInOut.speed(1.5)) {
                            self.pressFinish()
                        }
                    }) {
                        HStack {
                            Spacer()
                            
                            Text(state.exerciseStates.count > 0 ? "Save" : "Cancel")
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
        }
    }
}

public struct EditableWorkoutMetaMetricsView: View {
    @EnvironmentObject var state: WorkoutCreateState
    
    @ObservedObject var stopwatch: Stopwatch
    
    var showDate = true
    
    var totalWeight: Int {
        let result = state.exerciseStates.reduce(Float.zero) { (r, s) in
            if let e = s.exercise {
                let weight = e.data.displayWeightValue * Float(e.data.sets) * Float(e.data.reps)
                return weight + r
            }
            
            return r
        }
        
        return Int(round(result))
    }
    
    var totalDistance: Float {
        let result = state.exerciseStates.reduce(Float.zero) { (r, s) in
            if let e = s.exercise {
                return r + e.data.displayDistanceValue
            }
            
            return r
        }
        
        return result
    }
    
    var totalSets: Int {
        let result = state.exerciseStates.reduce(Int.zero) { (r, s) in
            if let e = s.exercise {
                return r + e.data.sets
            }
            
            return r
        }
        
        return result
    }
    
    var totalReps: Int {
        let result = state.exerciseStates.reduce(Int.zero) { (r, s) in
            if let e = s.exercise {
                return r + e.data.reps
            }
            
            return r
        }
        
        return result
    }
    
    public var body: some View {
        HStack(spacing: 10) {
            if showDate {
                WorkoutDetail(
                    name: self.state.date.abbreviatedMonthString,
                    value: self.state.date.dayString
                )
                
                DividerSpacer()
            }
            
            WorkoutDetail(
                name: "Time",
                value: secondsToElapsedTimeString(stopwatch.counter)
            )
                .fixedSize()
            
            DividerSpacer()
            
            WorkoutDetail(
                name: "Sets",
                value: "\(self.totalSets)"
            )
            
            DividerSpacer()
            
            WorkoutDetail(
                name: "Reps",
                value: "\(self.totalReps)"
            )
            
            DividerSpacer()
            
            WorkoutDetail(
                name: "Distance",
                value: "\(totalDistance) mi"
            )
        }
    }
}

#if DEBUG
struct CreateWorkoutView_Previews : PreviewProvider {
    static var previews: some View {
        let workoutEditorState = WorkoutCreateState()
        workoutEditorState.exerciseStates = [
            ExerciseEditState(input: "3x3 tricep curls"),
            ExerciseEditState(input: "4 mins of running")
        ]
        
        return WorkoutCreateView()
            .environmentObject(workoutEditorState)
            .environmentObject(RouteState(current: .editor))
            .environmentObject(MockWorkoutAPI(userState: UserState()) as WorkoutAPI)
            .environmentObject(MockExerciseAPI(userState: UserState()) as ExerciseAPI)
    }
}
#endif
