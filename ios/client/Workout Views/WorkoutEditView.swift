//
//  EditWorkoutView.swift
//  client
//
//  Created by Nadir Muzaffar on 5/22/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

import SwiftUI
import Introspect
import Combine
import Alamofire
import MapKit
import UIKit
import Foundation

public struct WorkoutEditView: View {
    @EnvironmentObject var routeState: RouteState
    @EnvironmentObject var workoutState: WorkoutCreateState
    @EnvironmentObject var workoutAPI: WorkoutAPI
    
    var workout: Workout
    
    private var locationManager = LocationManager()
    private var stopwatch = Stopwatch()
    private var suggestions = ExcerciseUserSuggestions()
    
    @State private var location: Location? = nil
    @State private var newEntryTextField: UITextField? = nil
    @State private var workoutNameTextField: UITextField? = nil
    @State private var newEntryState: ExerciseEditState = ExerciseEditState(input: "")
    
    init(workout: Workout) {
        self.workout = workout
        
        self.workoutState.exerciseStates = workout.exercises.map({ (e) -> ExerciseEditState in
            <#code#>
        })
        
        self.stopwatch.start()
    }
    
    func pressPause() {
        #if targetEnvironment(simulator)
        self.location = Location(latitude: 37.34727983131215, longitude: -121.88308869874288)
        #else
        let coord: CLLocationCoordinate2D? = locationManager.lastLocation?.coordinate
        self.location = coord != nil ? Location(latitude: coord!.latitude, longitude: coord!.longitude) : nil
        #endif
        
        self.stopwatch.stop()
        self.workoutState.isStopped = true
    }
    
    func pressResume() {
        self.stopwatch.start()
        self.workoutState.isStopped = false
    }
    
    func pressFinish() {
        let exercises: [Exercise] = workoutState.exerciseStates.map{ a in Exercise(raw: a.input) }
        let name = workoutState.workoutName.isEmpty ? dateToWorkoutName(self.workoutState.date) : workoutState.workoutName
        
        let workout = Workout(
            name: name,
            date: self.workoutState.date,
            exercises: exercises,
            location: self.location,
            secondsElapsed: stopwatch.counter
        )
        
        if exercises.count == 0 {
            self.workoutState.reset()
            self.routeState.replaceCurrent(with: .userFeed)
            return
        }
        
        workoutAPI.createWorkout(workout: workout) { (_) in
            self.workoutState.reset()
            self.routeState.replaceCurrent(with: .userFeed)
        }
    }
    
    func removeExerciseStateElement(state: ExerciseEditState) {
        self.workoutState.exerciseStates.removeAll(where: { e in
            return e === state
        })
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if workoutState.isStopped {
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
            
            if workoutState.isStopped {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Workout name")
                        .font(.caption)
                        .padding([.leading, .top])
                        .padding(.bottom, 3)
                        .foregroundColor(Color.gray)
                    
                    TextField(dateToWorkoutName(self.workoutState.date), text: $workoutState.workoutName, onCommit: {
                        self.workoutState.workoutName = self.workoutState.workoutName.trimmingCharacters(in: .whitespaces)
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
                showDate: workoutState.isStopped
            )
                .fixedSize(horizontal: workoutState.isStopped, vertical: true)
                .padding(workoutState.isStopped ? [.leading] : [.top, .trailing, .leading])
                .padding(.bottom, workoutState.isStopped ? 5 : 20)
            
            if workoutState.isStopped {
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
                    ForEach(self.workoutState.exerciseStates, id: \.id) { (exerciseState: ExerciseEditState) in
                        VStack(spacing: 0) {
                            ExerciseEditView(
                                state: exerciseState,
                                suggestions: self.suggestions,
                                onUserInputCommit: { _ in
                                    DispatchQueue.main.async {
                                        if exerciseState.input.isEmpty {
                                            self.workoutState.exerciseStates.removeAll(where: { ex in
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
                        .modifier(DeletableViewModifier(disable: self.workoutState.isStopped, onClick: {
                            self.removeExerciseStateElement(state: exerciseState)
                        }))
                    }
                    
                    if !self.workoutState.isStopped {
                        VStack(spacing: 0) {
                            ExerciseEditView(
                                state: self.newEntryState,
                                isNewEntry: true,
                                suggestions: self.suggestions,
                                onUserInputCommit: { (textField: UITextField) in
                                    DispatchQueue.main.async {
                                        if !self.newEntryState.input.isEmpty {
                                            self.workoutState.exerciseStates.append(self.newEntryState)
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
                if !workoutState.isStopped {
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
                            
                            Text(workoutState.exerciseStates.count > 0 ? "Save" : "Cancel")
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
