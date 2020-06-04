//
//  ExerciseEditorView.swift
//  client
//
//  Created by Nadir Muzaffar on 3/20/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Combine
import SwiftUI
import Alamofire

typealias TextFieldHandler = ((UITextField) -> Void)

public struct ExerciseEditView: View {
    @EnvironmentObject var workoutState: WorkoutCreateState
    @EnvironmentObject var exerciseAPI: ExerciseAPI
    
    @ObservedObject var exerciseState: ExerciseEditState
    @ObservedObject var suggestions: ExcerciseUserSuggestions
    
    private var isNewEntry: Bool
    private var shouldResolveExercise: Bool
    private var becomeFirstResponderOnAppear: Bool
    private var userInputCommitHandler: TextFieldHandler
    private var textFieldChangeHandler: TextFieldHandler
    
    @State private var resolveExerciseRequest: DataRequest?
    @State private var textField: UITextField? = nil
    @State private var cancellable: AnyCancellable? = nil
    @State private var dragOffset = CGSize.zero
    
    init(
        state: ExerciseEditState,
        isNewEntry: Bool = false,
        suggestions: ExcerciseUserSuggestions = ExcerciseUserSuggestions(),
        shouldResolveExercise: Bool = true,
        becomeFirstResponderOnAppear: Bool = false,
        onUserInputCommit: @escaping TextFieldHandler = { _ in },
        onTextFieldChange: @escaping TextFieldHandler = { _ in }
    ) {
        self.exerciseState = state
        self.isNewEntry = isNewEntry
        self.suggestions = suggestions
        self.shouldResolveExercise = shouldResolveExercise
        self.becomeFirstResponderOnAppear = becomeFirstResponderOnAppear
        self.userInputCommitHandler = onUserInputCommit
        self.textFieldChangeHandler = onTextFieldChange
    }
    
    private func resolveRawExercise() {
        if !shouldResolveExercise {
            return
        }
        
        if let req = resolveExerciseRequest {
            resolveExerciseRequest = nil
            req.cancel()
        }

        // we do this just for viewing purposes
        var exercise = Exercise(raw: exerciseState.input)
        if let oldExercise = self.exerciseState.exercise {
            exercise = Exercise(id: oldExercise.id, raw: exerciseState.input)
        }
        
        self.exerciseState.exercise = exercise

        self.resolveExerciseRequest = exerciseAPI.resolveExercise(exercise: exercise) { resolvedExercise in
            self.exerciseState.exercise = resolvedExercise
        }
    }

    private var defaultText: String {
        self.suggestions.current?.raw ?? "Enter Exercise"
    }

    private var exercise: Exercise? {
        if isNewEntry {
            return suggestions.current
        }

        return exerciseState.exercise
    }
    
    var exerciseViewDisplayType: ExerciseViewDisplayType {
        if isNewEntry {
            return .tertiary
        } else if workoutState.isStopped {
            return .primary
        } else {
            return .secondary
        }
    }
    
    public var body: some View {
        return VStack(alignment: .leading, spacing: 0) {
            if !workoutState.isStopped {
                TextField(
                    exercise?.raw ?? "Enter your exercise",
                    text: $exerciseState.input,
                    onCommit: {
                        if !self.exerciseState.input.isEmpty && !self.isNewEntry {
                            self.resolveRawExercise()
                        }
                        
                        self.userInputCommitHandler(self.textField!)
                        self.suggestions.reset()
                    }
                )
                    .font(.body) // TODO: does this do anything?
                    .onAppear {
                        if !self.isNewEntry && (self.exercise == nil || self.exercise?.type == "") {
                            self.resolveRawExercise()
                        }
                    }
                    .introspectTextField { (textField: UITextField) in
                        if self.textField != textField {
                            textField.autocorrectionType = UITextAutocorrectionType.no
                            textField.returnKeyType = .next

                            if self.isNewEntry {
                                self.cancellable = self.exerciseState.$input.sink { value in
                                    if value.isEmpty {
                                        self.suggestions.reset()
                                    }
                                }
                            }
                            
                            if self.becomeFirstResponderOnAppear {
                                textField.becomeFirstResponder()
                            }
                            
                            self.textFieldChangeHandler(textField)
                        }
                        self.textField = textField
                    }
            }

            if exercise != nil && exercise!.correctiveCode > 0 {
                CorrectiveExerciseView(exercise: exercise!, showRawString: workoutState.isStopped)
            } else if exercise?.type == "" && !exerciseState.input.isEmpty && !isNewEntry {
                ProcessingExerciseView(exercise: workoutState.isStopped ? exercise : nil)
            } else if exercise == nil || (!exerciseState.input.isEmpty && isNewEntry) {
                WaitingForExerciseView()
            } else { 
                ExerciseView(
                    exercise: exercise!,
                    displayType: self.exerciseViewDisplayType
                )
            }
        }
            .padding([.leading, .trailing])
    }
}

class ExcerciseUserSuggestions: ObservableObject {
    @Published var current: Exercise? = nil
    private var index = 0
    private var timer: Timer? = nil
    private var options = [
        Exercise(
            name: "Tricep curls",
            raw: "3x3 tricep curls",
            data: ExerciseData(sets: 3, reps: 3, weight: 0, time: 0, distance: 0)
        ),
        Exercise(
            name: "Running",
            raw: "ran 3.3 miles in 7 mins",
            data: ExerciseData(sets: 0, reps: 0, weight: 0, time: 420, distance: 11.27)
        ),
        Exercise(
            name: "Kettlebell swings",
            raw: "12 kettlebell swings",
            data: ExerciseData(sets: 1, reps: 12, weight: 0, time: 0, distance: 0)
        ),
        Exercise(
            name: "Rowing",
            raw: "rowing 4km in 16 mins",
            data: ExerciseData(sets: 1, reps: 0, weight: 0, time: 960, distance: 4)
        ),
        Exercise(
            name: "Bench press",
            raw: "bench press 3x3 - 35 lbs",
            data: ExerciseData(sets: 3, reps: 3, weight: 35, time: 0, distance: 0)
        )
    ]
    
    init() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
            DispatchQueue.main.async {
                self.index = (self.index + 1) % (self.options.count + 2)

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
}

struct ExerciseEditorView_Previews: PreviewProvider {
    
    static var previews: some View {
        ScrollView {
            ExerciseEditView(state: ExerciseEditState(input: "3x3 tricep curls"))
            ExerciseEditView(state: ExerciseEditState(input: "3x3 tricep curls"))
            ExerciseEditView(state: ExerciseEditState(input: "3x3 tricep curls"), shouldResolveExercise: false)
            ExerciseEditView(state: ExerciseEditState(input: "3x3 tricep curls"))
        }
            .environmentObject(MockExerciseAPI(userState: UserState()) as ExerciseAPI)
            .environmentObject(WorkoutCreateState())
    }
}
