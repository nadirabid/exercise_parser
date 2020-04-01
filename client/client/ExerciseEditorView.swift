//
//  ExerciseEditorView.swift
//  client
//
//  Created by Nadir Muzaffar on 3/20/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Combine
import SwiftUI

public struct EditableExerciseView: View {
    @EnvironmentObject var state: EditableWorkoutState
    @EnvironmentObject var exerciseAPI: ExerciseAPI
    @ObservedObject var exerciseState: EditableExerciseState
    @State var isNewEntryField: Bool = false
    @State var resolveExercise: Bool = true
    var onUserInputCommit: (() -> Void)? = nil
    
    @State private var textField: UITextField?
    @State private var cancellable: AnyCancellable? = nil
    private var enteries: ExerciseDefaultEntries?
    
    init(
        exerciseState: EditableExerciseState,
        isNewEntryField: Bool = false,
        resolveExercise: Bool = true,
        onUserInputCommit: @escaping (() -> Void) = {}
    ) {
        self.exerciseState = exerciseState
        self.isNewEntryField = isNewEntryField
        self.resolveExercise = resolveExercise
        self.onUserInputCommit = onUserInputCommit
        
        if isNewEntryField {
            enteries = ExerciseDefaultEntries()
        }
    }
    
    private func resolveRawExercise() {
        if !resolveExercise || exerciseState.exercise != nil {
            return
        }
        
        // we do this just for viewing purposes
        let exercise = Exercise(raw: exerciseState.input)
        self.exerciseState.exercise = exercise

        exerciseAPI.resolveExercise(exercise: exercise) { resolvedExercise in
            self.exerciseState.exercise = resolvedExercise
        }
    }
    
    private func showActivityView() -> Bool {
        return !self.isNewEntryField &&
            exerciseState.exercise != nil &&
            exerciseState.exercise?.type != "unknown"
    }
    
    private var defaultText: String {
        if isNewEntryField {
            return self.enteries?.current?.raw ?? "Enter Exercise"
        } else {
            return ""
        }
    }
    
    public var body: some View {
        return VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                if !state.isStopped {
                    TextField(
                        defaultText,
                        text: $exerciseState.input,
                        onCommit: {
                            self.onUserInputCommit?()
                        }
                    )
                        .font(.body) // TODO: does this do anything?
                        .onAppear {
                            if !self.isNewEntryField {
                                self.resolveRawExercise()
                            }
                        }
                        .introspectTextField { (textField: UITextField) in
                            if self.textField != textField {
                                textField.autocorrectionType = UITextAutocorrectionType.no
                                textField.returnKeyType = .next
                                
                                if self.isNewEntryField {
                                    textField.becomeFirstResponder()
                                    
                                    self.cancellable = self.state.$newEntry.sink { value in
                                        if value.isEmpty {
                                            self.enteries?.reset()
                                        }
                                    }
                                }
                            }
                            self.textField = textField
                        }
                }
                
                if self.showActivityView() {
                    ExerciseView(exercise: exerciseState.exercise!, asSecondary: !state.isStopped)
                } else {
                    ProcessingExerciseView()
                }
            }
                .padding([.leading, .trailing])
            
            Divider()
                .padding([.top, .bottom], 10)
        }
    }
}

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

struct ExerciseEditorView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            EditableExerciseView(exerciseState: EditableExerciseState(input: "3x3 tricep curls"))
            EditableExerciseView(exerciseState: EditableExerciseState(input: "3x3 tricep curls"))
            EditableExerciseView(exerciseState: EditableExerciseState(input: "3x3 tricep curls"), resolveExercise: false)
            EditableExerciseView(exerciseState: EditableExerciseState(input: "3x3 tricep curls"))
        }
            .environmentObject(MockExerciseAPI(userState: UserState()) as ExerciseAPI)
            .environmentObject(EditableWorkoutState())
    }
}
