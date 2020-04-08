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

public struct EditableExerciseView: View {
    @EnvironmentObject var workoutState: EditableWorkoutState
    @EnvironmentObject var exerciseAPI: ExerciseAPI
    @ObservedObject var exerciseState: EditableExerciseState
    @ObservedObject var suggestions: ExcerciseUserSuggestions
    
    private var isNewEntry: Bool
    private var shouldResolveExercise: Bool
    private var userInputCommitHandler: TextFieldHandler
    private var textFieldChangeHandler: TextFieldHandler
    
    @State private var resolveExerciseRequest: DataRequest?
    @State private var textField: UITextField? = nil
    @State private var cancellable: AnyCancellable? = nil
    @State private var test: String = ""
    
    init(
        state: EditableExerciseState,
        isNewEntry: Bool = false,
        suggestions: ExcerciseUserSuggestions = ExcerciseUserSuggestions(),
        shouldResolveExercise: Bool = true,
        onUserInputCommit: @escaping TextFieldHandler = { _ in },
        onTextFieldChange: @escaping TextFieldHandler = { _ in }
    ) {
        self.exerciseState = state
        self.isNewEntry = isNewEntry
        self.suggestions = suggestions
        self.shouldResolveExercise = shouldResolveExercise
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
        let exercise = Exercise(raw: exerciseState.input)
        self.exerciseState.exercise = exercise

        self.resolveExerciseRequest = exerciseAPI.resolveExercise(exercise: exercise) { resolvedExercise in
            self.exerciseState.exercise = resolvedExercise
        }
    }

    private func showActivityView() -> Bool {
        return exerciseState.exercise != nil && exerciseState.exercise?.type != ExerciseType.unknown.rawValue
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
    
    public var body: some View {
        return VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
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
                            if !self.isNewEntry {
                                self.resolveRawExercise()
                            }
                        }
                        .introspectTextField { (textField: UITextField) in
                            if self.textField != textField {
                                textField.autocorrectionType = UITextAutocorrectionType.no
                                textField.returnKeyType = .next

                                if self.isNewEntry {
                                    textField.becomeFirstResponder()
                                    
                                    self.cancellable = self.exerciseState.$input.sink { value in
                                        if value.isEmpty {
                                            self.suggestions.reset()
                                        }
                                    }
                                }
                                
                                self.textFieldChangeHandler(textField)
                            }
                            self.textField = textField
                        }
                }

                if exercise?.type == ExerciseType.unknown.rawValue &&
                    !exerciseState.input.isEmpty &&
                    !isNewEntry {
                    ProcessingExerciseView()
                } else if exercise == nil ||
                    (!exerciseState.input.isEmpty && isNewEntry) {
                    WaitingForExerciseView()
                } else {
                    ExerciseView(
                        exercise: exercise!,
                        asSecondary: !workoutState.isStopped || self.isNewEntry
                    )
                        .transition(self.isNewEntry ? AnyTransition.moveUpAndFade() : AnyTransition.identity)
                        .id("exercise_\(exercise!.raw)")
                }
            }
                .padding([.leading, .trailing])

            Divider()
                .padding([.top], 10)
        }
    }
}

class ExcerciseUserSuggestions: ObservableObject {
    @Published var current: Exercise? = nil
    private var index = 0
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
            DispatchQueue.main.async {
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
    }
    
    func reset() {
        self.index = self.options.count
        self.current = nil
    }
}

struct ExerciseEditorView_Previews: PreviewProvider {
    
    static var previews: some View {
        ScrollView {
            EditableExerciseView(state: EditableExerciseState(input: "3x3 tricep curls"))
            EditableExerciseView(state: EditableExerciseState(input: "3x3 tricep curls"))
            EditableExerciseView(state: EditableExerciseState(input: "3x3 tricep curls"), shouldResolveExercise: false)
            EditableExerciseView(state: EditableExerciseState(input: "3x3 tricep curls"))
        }
            .environmentObject(MockExerciseAPI(userState: UserState()) as ExerciseAPI)
            .environmentObject(EditableWorkoutState())
    }
}
