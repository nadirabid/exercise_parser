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
import MapKit
import UIKit
import Foundation

public struct WorkoutEditView: View {
    @EnvironmentObject var routeState: RouteState
    @EnvironmentObject var workoutState: WorkoutCreateState
    @EnvironmentObject var userFeedState: UserFeedState
    @EnvironmentObject var workoutAPI: WorkoutAPI
    
    var workout: Workout
    
    private var locationManager = LocationManager()
    private var stopwatch = Stopwatch()
    private var suggestions = ExcerciseUserSuggestions()
    
    @State private var location: Location? = nil
    @State private var newEntryTextField: UITextField? = nil
    @State private var workoutNameTextField: UITextField? = nil
    @State private var newEntryState: ExerciseEditState = ExerciseEditState(input: "")
    @State private var isNewEntryTextFieldFirstResponder = false
    
    @State private var isCircuitEnabled = false
    @State private var circuitIDCounter = 0
    @State private var showRoundsPickerForCircuitID: Int? = nil
    @State private var _circuitRounds: Int = 2
    
    @State private var keyboardHeight: CGFloat = 0
    @State private var keyboardAnimationDuration: Double = 0
    
    init(workout: Workout) {
        self.workout = workout
    }
  
    func pressSave() {
        let exercises: [Exercise] = workoutState.exerciseStates.map { (s: ExerciseEditState) in
            return Exercise(id: s.exercise!.id, raw: s.input, circuitID: s.circuitID, circuitRounds: s.circuitRounds)
        }
        
        let name = workoutState.workoutName.isEmpty ? dateToWorkoutName(self.workoutState.date) : workoutState.workoutName
        
        let workout = Workout(
            id: self.workout.id,
            name: name,
            exercises: exercises
        )
        
        if exercises.count == 0 {
            self.workoutState.reset()
            self.routeState.replaceCurrent(with: .userFeed)
            return
        }
        
        workoutAPI.updateWorkout(workout: workout).then { (updatedWorkout) in
            self.userFeedState.workouts.update(with: updatedWorkout)
            self.workoutState.reset()
            
            withAnimation(Animation.easeInOut.speed(1.5)) {
                self.routeState.editWorkout = nil
            }
        }
    }
    
    func removeExerciseStateElement(state: ExerciseEditState) {
        self.workoutState.exerciseStates.removeAll(where: { e in
            return e === state
        })
    }
    
    func shouldShowPaddedDividerForLastEnteredExercise(_ exerciseState: ExerciseEditState) -> Bool {
        if exerciseState.circuitID != nil && workoutState.exerciseStates.last == exerciseState && self.isCircuitEnabled {
            return true
        }
        
        let i = workoutState.exerciseStates.firstIndex(of: exerciseState)
        if exerciseState.circuitID != nil && workoutState.exerciseStates.last != exerciseState && workoutState.exerciseStates[workoutState.exerciseStates.index(after: i!)].circuitID == exerciseState.circuitID  {
            return true
        }
        
        return false
    }
    
    func shouldShowRoundsBeforeExercise(_ exerciseState: ExerciseEditState) -> Int? { // non nil return is interpreted as true
        if workoutState.exerciseStates.first == exerciseState && exerciseState.circuitID != nil {
            return exerciseState.circuitRounds
        }
        
        if exerciseState.circuitID != nil && workoutState.exerciseStates.first(where: { $0.circuitID == exerciseState.circuitID }) == exerciseState {
            return exerciseState.circuitRounds
        }
        
        return nil
    }
    
    func updateKeyboardHeight(_ notification: Notification) {
        guard let info = notification.userInfo else { return }
        
        keyboardAnimationDuration = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
        
        guard let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        // If the top of the frame is at the bottom of the screen, set the height to 0.
        if keyboardFrame.origin.y == UIScreen.main.bounds.height {
            keyboardHeight = 0
        } else {
            // IMPORTANT: This height will _include_ the SafeAreaInset height.
            keyboardHeight = keyboardFrame.height
        }
    }
    
    var circuitRounds: Binding<Int> {
        return Binding<Int>(
            get: { () -> Int in
                return self._circuitRounds
        },
            set: { (value) in
                self._circuitRounds = value
                
                if self.showRoundsPickerForCircuitID != nil && self.showRoundsPickerForCircuitID! >= 0 {
                    let exerciseStates = self.workoutState.exerciseStates.filter { $0.circuitID == self.showRoundsPickerForCircuitID }
                    for exerciseState in exerciseStates {
                        exerciseState.circuitRounds = value
                    }
                }
        }
        )
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack {
                HStack(alignment: .center) {
                    Button(action: { self.routeState.editWorkout = nil }) {
                        Text("Cancel")
                    }
                    .padding(.leading)
                    
                    Spacer()
                }
                Divider()
            }
            
            ScrollView(showsIndicators: false) {
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
                    
                    EditableWorkoutMetaMetricsView(
                        stopwatch: stopwatch,
                        showDate: true
                    )
                        .fixedSize(horizontal: workoutState.isStopped, vertical: true)
                        .padding([.trailing, .leading])
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Exercises")
                            .font(.caption)
                            .padding([.leading, .top])
                            .padding(.bottom, 3)
                            .foregroundColor(Color.gray)
                    }
                }
            
                VStack(spacing: 0) {
                    ForEach(self.workoutState.exerciseStates, id: \.id) { exerciseState in
                        VStack(spacing: 0) {
                            if self.shouldShowRoundsBeforeExercise(exerciseState) != nil {
                                Button(action: {
                                    if self.showRoundsPickerForCircuitID == exerciseState.circuitID {
                                        self.showRoundsPickerForCircuitID = nil
                                    } else {
                                        self.showRoundsPickerForCircuitID = exerciseState.circuitID
                                        
                                        if let activeTextField = UIResponder.currentFirst() as? UITextField {
                                            activeTextField.resignFirstResponder()
                                        }
                                    }
                                }) {
                                    CircuitRoundsButtonView(
                                        circuitRounds: self.shouldShowRoundsBeforeExercise(exerciseState)!,
                                        isActive: self.showRoundsPickerForCircuitID == exerciseState.circuitID
                                    )
                                        .padding(.leading)
                                }
                            }
                            
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
                                        }
                                    },
                                    onEditingChanged: { changed, _ in
                                        if changed {
                                            DispatchQueue.main.async {
                                                self.showRoundsPickerForCircuitID = nil
                                                self.isNewEntryTextFieldFirstResponder = false
                                            }
                                        }
                                    }
                                )
                                    .padding([.top, .bottom], 6)
                                    .padding(.leading, exerciseState.circuitID == nil ? 0 : nil)
                                
                                Divider()
                                    .padding(.leading, self.shouldShowPaddedDividerForLastEnteredExercise(exerciseState) ? nil : 0)
                                    .animation(.none)
                            }
                            .modifier(DeletableViewModifier(disable: self.workoutState.isStopped) {
                                self.removeExerciseStateElement(state: exerciseState)
                            })
                        }
                    }
                    
                    VStack(spacing: 0) {
                        if isCircuitEnabled && self.workoutState.exerciseStates.last?.circuitID == nil {
                            Button(action: {
                                if self.showRoundsPickerForCircuitID == -1 {
                                    self.showRoundsPickerForCircuitID = nil
                                } else {
                                    self.showRoundsPickerForCircuitID = -1
                                    
                                    if let activeTextField = UIResponder.currentFirst() as? UITextField {
                                        activeTextField.resignFirstResponder()
                                    }
                                }
                            }) {
                                CircuitRoundsButtonView(
                                    circuitRounds: self.circuitRounds.wrappedValue,
                                    isActive: self.showRoundsPickerForCircuitID == -1
                                )
                                    .padding(.leading)
                            }
                        }
                        
                        ExerciseEditView(
                            state: self.newEntryState,
                            isNewEntry: true,
                            suggestions: self.suggestions,
                            becomeFirstResponderOnAppear: false,
                            onUserInputCommit: { (textField: UITextField) in
                                DispatchQueue.main.async {
                                    if !self.newEntryState.input.isEmpty {
                                        if self.isCircuitEnabled {
                                            self.newEntryState.circuitRounds = self.circuitRounds.wrappedValue
                                        }
                                        
                                        self.workoutState.exerciseStates.append(self.newEntryState)
                                        self.newEntryState = ExerciseEditState(input: "")
                                        
                                        if self.isCircuitEnabled {
                                            self.newEntryState.circuitID = self.circuitIDCounter
                                        } else if self.workoutState.exerciseStates.last?.circuitID == nil {
                                            self.circuitIDCounter += 1
                                        }
                                        
                                        textField.becomeFirstResponder()
                                    }
                                }
                            },
                            onTextFieldChange: { (textField: UITextField) in
                                self.newEntryTextField = textField
                            },
                            onEditingChanged: { changed, _ in
                                if changed {
                                    DispatchQueue.main.async {
                                        self.isNewEntryTextFieldFirstResponder = true
                                        self.showRoundsPickerForCircuitID = nil
                                    }
                                }
                            }
                        )
                            .padding([.top, .bottom], 6)
                            .padding(.leading, self.isCircuitEnabled ? nil : 0)
                        
                        Divider().animation(.none)
                    }
                }
            }
            .animation(.none)
            
            VStack(spacing: 0) {
                Divider()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation(Animation.easeInOut.speed(1.5)) {
                            self.pressSave()
                        }
                    }) {
                        Image(systemName:"waveform.path.ecg")
                            .font(.system(size: 15, weight: .medium, design: .default))
                            .foregroundColor(Color.secondary)
                        
                        Text("Save")
                            .foregroundColor(Color.secondary)
                    }
                    
                    if self.isNewEntryTextFieldFirstResponder || self.showRoundsPickerForCircuitID == -1 {
                        Spacer()
                        Divider()
                        Spacer()
                        
                        Button(action: {
                            withAnimation(Animation.easeInOut.speed(1.5)) {
                                self.isCircuitEnabled.toggle()
                                
                                if self.isCircuitEnabled {
                                    self.newEntryState.circuitID = self.circuitIDCounter
                                } else {
                                    self.showRoundsPickerForCircuitID = nil
                                    self.newEntryState.circuitID = nil
                                    
                                    self.newEntryTextField?.becomeFirstResponder()
                                }
                                
                                if self.isCircuitEnabled && self.workoutState.exerciseStates.last?.circuitID == nil {
                                    self.showRoundsPickerForCircuitID = -1
                                    self.newEntryTextField?.resignFirstResponder()
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "repeat")
                                    .font(.system(size: 12, weight: .medium, design: .default))
                                    .foregroundColor(self.isCircuitEnabled ? appColor : Color.secondary)
                                
                                Text("Circuit")
                                    .foregroundColor(self.isCircuitEnabled ? appColor : Color.secondary)
                            }
                        }
                    }
                    
                    if self.showRoundsPickerForCircuitID != nil {
                        Spacer()
                        Divider()
                        Spacer()
                        
                        Button(action: {
                            self.showRoundsPickerForCircuitID = nil
                            self.newEntryTextField?.becomeFirstResponder()
                        }) {
                            Image(systemName: "arrow.turn.right.down")
                                .font(.system(size: 12, weight: .medium, design: .default))
                                .foregroundColor(Color.secondary)
                            
                            Text("Enter")
                                .foregroundColor(Color.secondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.all, 13)
                .fixedSize(horizontal: false, vertical: true)
            }
            
            if self.showRoundsPickerForCircuitID != nil && keyboardHeight == 0 {
                CircuitRoundsPickerView(
                    circuitRounds: self.circuitRounds,
                    keyboardAnimationDuration: keyboardAnimationDuration
                )
            }
        }
        .keyboardObserving()
        .edgesIgnoringSafeArea(self.showRoundsPickerForCircuitID != nil ? [.bottom] : [])
        .onReceive(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification).receive(on: RunLoop.main),
            perform: updateKeyboardHeight
        )
        .onAppear {
                self.workoutState.workoutName = self.workout.name
                self.workoutState.exerciseStates = self.workout.exercises.map({ e in
                    return ExerciseEditState(exercise: e)
                })
        }
        .onDisappear {
            self.workoutState.reset()
        }
    }
}
