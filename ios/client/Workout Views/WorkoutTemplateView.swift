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
    
    var workout: Workout
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
    
    var exercisesToDisplay: [Exercise] {
        return workout.exercises.sorted(by: { $0.id! < $1.id! })
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text(workout.name)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding(.leading)
            
            
            WorkoutMetaMetricsView(workout: workout)
                .fixedSize(horizontal: true, vertical: true)
                .padding(.leading)
            
            if view == "waveform.path.ecg" {
                VStack(spacing: 0) {
                    ForEach(exercisesToDisplay) { (exercise: Exercise) in
                        ExerciseTemplateView(exerciseTemplate: ExerciseTemplate())
                            .padding(.top)
                    }
                }
                .padding([.leading, .trailing])
            } else {
                WorkoutMuscleMetricsView(workout: self.workout)
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
            if self.workout.isRunWorkout {
                return ActionSheet(title: Text(workout.name), buttons: [
                    .destructive(Text("Delete")) { self.onDelete() },
                    .cancel()
                ])
            }
            
            return ActionSheet(title: Text(workout.name), buttons: [
                .default(Text("Edit")) { self.routeState.editWorkout = self.workout },
                .destructive(Text("Delete")) { self.onDelete() },
                .cancel()
            ])
        }
    }
}

struct WorkoutTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutTemplateView(workout: Workout(
            name: "Leg workout",
            date: Date(),
            exercises: [
                Exercise(name: "Squats", raw: "squats 3x5 150lbs", data: ExerciseData(
                    sets: 3, reps: 5, weight: 150, time: 0, distance: 0
                )),
                Exercise(name: "Squats", raw: "squats 3x5 150lbs", data: ExerciseData(
                    sets: 3, reps: 5, weight: 150, time: 0, distance: 0
                )),
                Exercise(name: "Squats", raw: "squats 3x5 150lbs", data: ExerciseData(
                    sets: 3, reps: 5, weight: 150, time: 0, distance: 0
                )),
                Exercise(name: "Squats", raw: "squats 3x5 150lbs", data: ExerciseData(
                    sets: 3, reps: 5, weight: 150, time: 0, distance: 0
                ))
            ],
            inProgress: false
        ))
    }
}
