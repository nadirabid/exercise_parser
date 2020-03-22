//
//  ExerciseEditorView.swift
//  client
//
//  Created by Nadir Muzaffar on 3/20/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

public struct ExerciseEditorView: View {
    @EnvironmentObject var exerciseAPI: ExerciseAPI
    @ObservedObject var activity: UserActivity
    @State var resolveExercise = true
    var textFieldContext: UITextField?
    
    func resolveRawExercise(userActivity: UserActivity) {
        // we do this just for viewing purposes
        let exercise = Exercise(raw: userActivity.input)
        
        exerciseAPI.resolveExercise(exercise: exercise) { e in
            self.activity.exercise = e
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                TextField("", text: $activity.input, onCommit: {
                    self.textFieldContext!.becomeFirstResponder()
                })
                    .font(.body)
                    .onAppear {
                        if self.activity.exercise == nil && self.resolveExercise {
                            self.resolveRawExercise(userActivity: self.activity)
                        }
                    }
                
                if activity.exercise != nil {
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
    }
}
