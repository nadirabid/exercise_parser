//
//  WorkoutTemplateView.swift
//  client
//
//  Created by Nadir Muzaffar on 6/25/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct WorkoutTemplateView: View {
    @EnvironmentObject var userAPI: UserAPI
    @EnvironmentObject var routeState: RouteState
    
    var template: WorkoutTemplate
    var onDelete: () -> Void = {}
    
    var options = [ "waveform.path.ecg", "function" ]
    
    @State private var view = "waveform.path.ecg"
    @State private var showingActionSheet = false
    
    func shouldShowRoundsBeforeExercise(_ exercise: Exercise) -> Bool {
        let firstExerciseOfCircuitID = exercisesToDisplay.first(where: { $0.circuitID == exercise.circuitID })
        if exercise.circuitID != nil && firstExerciseOfCircuitID != nil && exercise.id == firstExerciseOfCircuitID!.id {
            return true
        }
        
        return false
    }
    
    var exercisesToDisplay: [ExerciseTemplate] {
        return template.exercises.sorted(by: { $0.id! < $1.id! })
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text(template.name)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding(.leading)
            
//            WorkoutMetaMetricsView(workout: workout)
//                .fixedSize(horizontal: true, vertical: true)
//                .padding(.leading)
            
            if view == "waveform.path.ecg" {
                VStack(spacing: 0) {
                    ForEach(exercisesToDisplay) { item in
                        ExerciseTemplateView(exerciseTemplate: item)
                            .padding(.top)
                    }
                }
                .padding([.leading, .trailing])
            } else {
                Text("MuscleMetrics")
                //WorkoutMuscleMetricsView(workout: self.workout)
            }
            
            HStack {
                Spacer()
                
                Picker(selection: self.$view, label: Text("View selection")) {
                    ForEach(options, id: \.self) { o in
                        VStack {
                            Image(systemName: o)
                                .font(.caption)
                                .tag(o)
                        }
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .fixedSize()
                
                Spacer()
            }
        }
        .padding([.top, .bottom])
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(title: Text(self.template.name), buttons: [
                .default(Text("Edit")) { print("Edit" )},
                .destructive(Text("Delete")) { print("Delete") },
                .cancel()
            ])
        }
    }
}
