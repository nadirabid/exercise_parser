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
    var textFieldContext: UITextField? = nil
    @State private var isButtonVisible = true
    
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
    
    func test() {
        isButtonVisible = !isButtonVisible
    }
    
    func showActivityView() -> Bool {
        return activity.exercise != nil && activity.exercise?.type != "unknown"
    }
    
    public var body: some View {
        return VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                if !state.isStopped {
                    TextField("", text: $activity.input.animation(), onCommit: {
                        self.textFieldContext?.becomeFirstResponder()
                    })
                        .font(.body)
                        .onAppear {
                            self.resolveRawExercise()
                        }
                }
                
                if self.showActivityView() {
                    ActivityView(exercise: activity.exercise!, asSecondary: true)
                } else {
                    ProcessingActivityView()
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
