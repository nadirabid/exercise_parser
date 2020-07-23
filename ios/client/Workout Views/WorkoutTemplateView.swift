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
    @EnvironmentObject var workoutTemplateAPI: WorkoutTemplateAPI
    
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
                    
                Button(action: { self.showingActionSheet = true }) {
                    Image(systemName:"ellipsis")
                        .background(Color.white)
                        .font(.headline)
                        .foregroundColor(Color.secondary)
                }
            }
            .padding([.leading, .trailing])
            
            WorkoutTemplateMetaMetricsView(workoutTemplate: self.template)
                .fixedSize(horizontal: true, vertical: true)
                .padding(.leading)
            
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
                .destructive(Text("Delete")) { self.onDelete() },
                .cancel()
            ])
        }
    }
}

public struct WorkoutTemplateMetaMetricsView: View {
    @State var workoutTemplate: WorkoutTemplate
    
    var totalWeight: Int {
        let result = workoutTemplate.exercises.reduce(Float.zero) { (r, e) in
            let circuitRounds = Float(e.circuitRounds > 1 ? e.circuitRounds : 1)
            let total = (0..<e.data.sets).reduce(Float.zero) { (result, i) in
                return circuitRounds * Float(e.data.reps[i]) * e.data.weight[i]
            }
            
            return total + r
        }
        
        return Int(round(result))
    }
    
    var totalDistanceUnits: String {
        let result = workoutTemplate.exercises.reduce(Float.zero) { (r, e) in
            let circuitRounds = Float(e.circuitRounds > 1 ? e.circuitRounds : 1)
            let total = (0..<e.data.sets).reduce(Float.zero) { (result, i) in
                return circuitRounds * Float(e.data.reps[i]) * e.data.distance[i]
            }
            return r + total
        }
        
        if result <= 300 {
            return UnitLength.feet.symbol
        }
        
        return UnitLength.miles.symbol
    }
    
    var totalDistance: Float {
        let result = workoutTemplate.exercises.reduce(Float.zero) { (r, e) in
            let circuitRounds = Float(e.circuitRounds > 1 ? e.circuitRounds : 1)
            let total = (0..<e.data.sets).reduce(Float.zero) { (result, i) in
                return circuitRounds * Float(e.data.reps[i]) * e.data.distance[i]
            }
            return r + total
        }
        
        var m = Measurement(value: Double(result), unit: UnitLength.meters)
        
        if result <= 300 {
            m = m.converted(to: UnitLength.feet)
        } else {
            m = m.converted(to: UnitLength.miles)
        }
        
        return Float(round(m.value*10)/10)
    }
    
    var totalReps: Int {
        let result = workoutTemplate.exercises.reduce(Int.zero) { (r, e) in
            let circuitRounds = e.circuitRounds > 1 ? e.circuitRounds : 1
            
            let total = (0..<e.data.sets).reduce(Int.zero) { (result, i) in
                if e.data.reps[i] <= 1 { // if reps is 1 or less - we're not going to show the count
                    return 0
                } else {
                    return e.data.reps[i] * circuitRounds
                }
            }
            
            return r + total
        }
        
        return result
    }
    
    var totalSets: Int {
        let result = workoutTemplate.exercises.reduce(Int.zero) { (r, e) in
            if e.data.sets <= 1 {
                return r
            }
            
            let circuitRounds = e.circuitRounds > 1 ? e.circuitRounds : 1
            return r + e.data.sets * circuitRounds
        }
        
        return result
    }
    
    var time: Int {
        return workoutTemplate.exercises.reduce(0) { (result, exerciseTemplate) in
            let total = (0..<exerciseTemplate.data.sets).reduce(0) { (result, i) in
                result + exerciseTemplate.data.time[i]
            }
            
            return result + total
        }
    }
    
    public var body: some View {
        HStack(spacing: 10) {
            WorkoutDetail(
                name: "Time",
                value: secondsToElapsedTimeString(time)
            )
            
            if totalSets > 1 {
                Divider()
                
                WorkoutDetail(name: "Sets", value:"\(totalSets.description)")
            }
            
            if totalReps > 1 {
                Divider()
                
                WorkoutDetail(name: "Reps", value:"\(totalReps.description)")
            }
            
            if totalDistance > 0 {
                Divider()
                
                WorkoutDetail(name: "Distance", value: "\(totalDistance) \(totalDistanceUnits)")
            }
        }
    }
}
