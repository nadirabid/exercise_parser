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
    @EnvironmentObject var workoutState: WorkoutCreateState
    @EnvironmentObject var workoutAPI: WorkoutAPI
    
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
        self.workoutState.isStopped = true
    }
    
    func pressResume() {
        self.stopwatch.start()
        self.workoutState.isStopped = false
    }
    
    func pressFinish() {
        let exercises: [Exercise] = workoutState.exerciseStates.map{ s in
            return Exercise(raw: s.input, circuitID: s.circuitID, circuitRounds: s.circuitRounds)
        }
        
        if exercises.count == 0 {
            self.workoutState.reset()
            self.route.replaceCurrent(with: .userFeed)
            return
        }
        
        let name = workoutState.workoutName.isEmpty ? dateToWorkoutName(self.workoutState.date) : workoutState.workoutName
        
        let workout = Workout(
            name: name,
            date: self.workoutState.date,
            exercises: exercises,
            location: self.location,
            secondsElapsed: stopwatch.counter
        )
        
        workoutAPI.createWorkout(workout: workout) { (_) in
            self.workoutState.reset()
            self.route.replaceCurrent(with: .userFeed)
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
                                            self.newEntryTextField?.becomeFirstResponder()
                                        }
                                },
                                    onEditingChanged: { changed in
                                        if changed {
                                            DispatchQueue.main.async {
                                                self.isNewEntryTextFieldFirstResponder = false
                                                self.showRoundsPickerForCircuitID = nil
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
                            .modifier(DeletableViewModifier(disable: self.workoutState.isStopped, onClick: {
                                self.removeExerciseStateElement(state: exerciseState)
                            }))
                        }
                    }
                    
                    if !self.workoutState.isStopped {
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
                                becomeFirstResponderOnAppear: true,
                                onUserInputCommit: { (textField: UITextField) in
                                    if !self.newEntryState.input.isEmpty {
                                        DispatchQueue.main.async {
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
                                onEditingChanged: { changed in
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
                            
                            Divider()
                        }
                    }
                }
            }
            .animation(.none)
            
            VStack(spacing: 0) {
                Divider()
                
                if !workoutState.isStopped {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            withAnimation(Animation.easeInOut.speed(1.5)) {
                                self.pressPause()
                            }
                        }) {
                            Image(systemName:"stop.circle")
                                .font(.system(size: 15, weight: .medium, design: .default))
                                .foregroundColor(Color.secondary)
                            
                            Text("Stop")
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
                                        
                                        if let activeTextField = UIResponder.currentFirst() as? UITextField {
                                            activeTextField.resignFirstResponder()
                                        }
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
                else {
                    HStack {
                        Button(action: {
                            withAnimation(Animation.easeInOut.speed(1.5)) {
                                self.pressFinish()
                            }
                        }) {
                            Image(systemName:"waveform.path.ecg")
                                .font(.system(size: 15, weight: .medium, design: .default))
                                .foregroundColor(Color.secondary)
                            
                            Text(workoutState.exerciseStates.count > 0 ? "Save" : "Cancel")
                                .foregroundColor(Color.secondary)
                        }
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
        }
        .keyboardObserving()
        .edgesIgnoringSafeArea(self.showRoundsPickerForCircuitID != nil ? [.bottom] : [])
        .onReceive(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification).receive(on: RunLoop.main),
            perform: updateKeyboardHeight
        )
    }
}

public struct CircuitRoundsPickerView: View {
    public var circuitRounds: Binding<Int>
    var keyboardAnimationDuration: Double = 0.25
    
    public var body: some View {
        ZStack {
            Picker(selection: self.circuitRounds, label: EmptyView()) {
                ForEach(2..<13, id: \.self) {
                    Text("\($0) rounds")
                }
                .padding()
            }
            .pickerStyle(WheelPickerStyle())
            .labelsHidden()
            .frame(width: UIScreen.main.bounds.width)
        }
        .background(Color(UIColor.systemGray5))
        .transition(.move(edge: .bottom))
        .animation(Animation.linear(duration: keyboardAnimationDuration))
        .zIndex(2)
    }
}

public struct CircuitRoundsButtonView: View {
    var circuitRounds: Int = 2
    var isActive: Bool = false
    
    public var body: some View {
        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Text(self.circuitRounds.description)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .allowsTightening(true)
                    .foregroundColor(self.isActive ? Color.white : Color.black)
                    .padding(4)
                    .frame(width: 30)
                    .fixedSize()
                    .animation(.none)
                    .background(
                        VStack {
                            if self.isActive {
                                Circle().fill(appColor)
                            } else {
                                Circle().stroke(appColor, lineWidth: 1)
                            }
                        }
                )
                
                Text("Rounds Circuit")
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(Color.primary)
                
                Spacer()
            }
            .padding([.top, .bottom], 11)
        }
        .transition(.scale)
        .animation(.default)
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

public struct DividerSpacer: View {
    public var body: some View {
        return HStack(spacing: 0) {
            Spacer()
            Divider()
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
