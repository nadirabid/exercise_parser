//
//  ExerciseEditorView.swift
//  client
//
//  Created by Nadir Muzaffar on 3/20/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

public struct ExerciseEditorView: View {
    @EnvironmentObject var state: WorkoutEditorState
    @EnvironmentObject var exerciseAPI: ExerciseAPI
    @ObservedObject var activity: UserActivity
    @State var resolveExercise = true
    var onTextFieldCommit: (() -> Void)? = nil
    
    @State private var textField: UITextField?
    
    func resolveRawExercise() {
        if !resolveExercise || activity.exercise != nil {
            return
        }
        
        // we do this just for viewing purposes
        let exercise = Exercise(raw: activity.input)

        exerciseAPI.resolveExercise(exercise: exercise) { e in
            self.activity.exercise = e
        }
    }
    
    func showActivityView() -> Bool {
        return activity.exercise != nil && activity.exercise?.type != "unknown"
    }
    
    public var body: some View {
        return VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                if !state.isStopped {
                    TextField("", text: $activity.input, onCommit: {
                        self.onTextFieldCommit?()
                    })
                        .font(.body)
                        .onAppear {
                            self.resolveRawExercise()
                        }
                        .introspectTextField { (textField: UITextField) in
                            if self.textField != textField {
                                textField.autocorrectionType = UITextAutocorrectionType.no
                                textField.returnKeyType = .next
                            }
                            self.textField = textField
                        }
                }
                
                if self.showActivityView() {
                    ExerciseView(exercise: activity.exercise!, asSecondary: !state.isStopped)
                } else {
                    ProcessingExerciseView(exercise: activity.exercise!)
                }
            }
            .padding([.leading, .trailing])
            
            Divider().padding([.top, .bottom], 10)
        }
    }
}

struct ExerciseEditorView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            ExerciseEditorView(activity: UserActivity(input: "3x3 tricep curls"))
            ExerciseEditorView(activity: UserActivity(input: "3x3 tricep curls"))
            ExerciseEditorView(activity: UserActivity(input: "3x3 tricep curls"), resolveExercise: false)
            ExerciseEditorView(activity: UserActivity(input: "3x3 tricep curls"))
        }
        .environmentObject(MockExerciseAPI(userState: UserState()) as ExerciseAPI)
        .environmentObject(WorkoutEditorState())
    }
}
