//
//  ActivityView.swift
//  client
//
//  Created by Nadir Muzaffar on 2/26/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct ExerciseView : View {
    var exercise: Exercise
    var asSecondary: Bool = false
    
    var body: some View {
        HStack {
            Text(exercise.name.capitalized)
                .font(.subheadline)
                .foregroundColor(asSecondary ? .secondary : .primary)
            
            Spacer()
            
            HStack {
                if exercise.type == "weighted" {
                    VStack(alignment: .trailing, spacing: 1.0) {
                        Text("sets")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(exercise.weightedExercise!.sets)")
                            .font(.headline)
                            .foregroundColor(self.asSecondary ? .secondary : .primary)
                    }
                        .padding(.leading, 2.0)
                    
                    VStack(alignment: .trailing, spacing: 1.0) {
                        Text("reps")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(exercise.weightedExercise!.reps)")
                            .font(.headline)
                            .foregroundColor(self.asSecondary ? .secondary : .primary)
                    }
                        .padding(.leading, 2.0)
                    
                    VStack(alignment: .trailing, spacing: 1.0) {
                        Text("lbs")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("x")
                            .font(.headline)
                            .foregroundColor(self.asSecondary ? .secondary : .primary)
                    }
                        .padding(.leading, 2.0)
                } else if exercise.type == "distance" {
                    VStack(alignment: .trailing, spacing: 1.0) {
                        Text(exercise.distanceExercise!.units)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(exercise.distanceExercise!.distance.format(f: ".1"))
                            .font(.headline)
                            .foregroundColor(self.asSecondary ? .secondary : .primary)
                    }
                        .padding(.leading, 2.0)
                }
            }
        }
    }
}

struct ProcessingExerciseView: View {
    var exercise: Exercise?
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading) {
                if exercise != nil {
                    Text(exercise!.raw)
                        .font(.subheadline)
                }
                
                Text("Now learning")
                    .font(.caption)
                    .foregroundColor(Color.gray)
            }
            
            Spacer()
            
            FancyLoader()
        }
    }
}

extension Float32 {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

#if DEBUG
struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        return VStack {
            ExerciseView(exercise: Exercise(id: 0, createdAt: "", updatedAt: "", name: "", type: "", raw: "", weightedExercise: nil, distanceExercise: nil))
            ExerciseView(exercise: Exercise(id: 0, createdAt: "", updatedAt: "", name: "", type: "", raw: "", weightedExercise: nil, distanceExercise: nil))
        }
        .environmentObject(MockExerciseAPI(userState: UserState()))
    }
}
#endif
