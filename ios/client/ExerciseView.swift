//
//  ActivityView.swift
//  client
//
//  Created by Nadir Muzaffar on 2/26/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

enum ExerciseViewDisplayType {
    case primary, secondary, tertiary
}

struct ExerciseView : View {
    var exercise: Exercise
    var displayType: ExerciseViewDisplayType = .primary
    
    var valuesColor: Color {
        switch displayType {
        case .primary:
            return .primary
        case .secondary:
            return .secondary
        case .tertiary:
            return Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
        }
    }
    
    var unitsColor: Color {
        switch displayType {
        case .primary, .secondary:
            return .secondary
        case .tertiary:
            return Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
        }
    }
    
    var shouldItalicize: Bool {
        switch displayType {
        case .primary, .secondary:
            return false
        case .tertiary:
            return true
        }
    }
    
    var body: some View {
        if exercise.data.distance > 0 {
        print(exercise.data.distance > 0, exercise.data.displayDistanceValue.format(f: ".1"), exercise.data.displayDistanceValue, exercise.data.distance)
        }
        return HStack {
            Text(exercise.name.capitalized)
                .font(.subheadline)
                .foregroundColor(self.valuesColor)
                .shouldItalicize(shouldItalicize)
            
            Spacer()
            
            HStack {
                if exercise.data.time > 0 {
                    VStack(alignment: .trailing, spacing: 1.0) {
                         Text("time")
                             .font(.caption)
                             .foregroundColor(self.unitsColor)
                             .shouldItalicize(shouldItalicize)
                         
                         Text(secondsToElapsedTimeString(exercise.data.time))
                             .font(.headline)
                             .foregroundColor(self.valuesColor)
                             .shouldItalicize(shouldItalicize)
                     }
                         .padding(.leading, 2.0)
                }
                
                if exercise.data.distance > 0 {
                    VStack(alignment: .trailing, spacing: 1.0) {
                        Text(exercise.data.displayDistanceUnits)
                              .font(.caption)
                              .foregroundColor(self.unitsColor)
                              .shouldItalicize(shouldItalicize)
                          
                          Text(exercise.data.displayDistanceValue.format(f: ".1"))
                              .font(.headline)
                              .foregroundColor(self.valuesColor)
                              .shouldItalicize(shouldItalicize)
                      }
                          .padding(.leading, 2.0)
                }
                
                if exercise.data.sets > 1 {
                    VStack(alignment: .trailing, spacing: 1.0) {
                        Text("sets")
                            .font(.caption)
                            .foregroundColor(self.unitsColor)
                            .shouldItalicize(shouldItalicize)
                        
                        Text("\(exercise.data.sets)")
                            .font(.headline)
                            .foregroundColor(self.valuesColor)
                            .shouldItalicize(shouldItalicize)
                    }
                        .padding(.leading, 2.0)
                }
                
                if exercise.data.reps > 1 {
                    VStack(alignment: .trailing, spacing: 1.0) {
                        Text("reps")
                            .font(.caption)
                            .foregroundColor(self.unitsColor)
                            .shouldItalicize(shouldItalicize)
                        
                        Text("\(exercise.data.reps)")
                            .font(.headline)
                            .foregroundColor(self.valuesColor)
                            .shouldItalicize(shouldItalicize)
                    }
                        .padding(.leading, 2.0)
                }
                
                if exercise.data.weight > 0 {
                    VStack(alignment: .trailing, spacing: 1.0) {
                           Text(exercise.data.displayWeightUnits)
                               .font(.caption)
                               .foregroundColor(self.unitsColor)
                               .shouldItalicize(shouldItalicize)
                           
                           Text(exercise.data.displayWeightValue.format(f: ".0"))
                               .font(.headline)
                               .foregroundColor(self.valuesColor)
                               .shouldItalicize(shouldItalicize)
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
                
                Text("Taking time to process")
                    .font(.caption)
                    .foregroundColor(Color.gray)
            }
            
            Spacer()
            
            FancyLoader()
        }
    }
}

struct WaitingForExerciseView: View {
    var body: some View {
        HStack {
            Text("Press next to complete")
                .font(.subheadline)
                .foregroundColor(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
            
            Spacer()
            
            FancyLoader()
        }
    }
}

#if DEBUG
struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        return VStack {
            Divider()
            
            ExerciseView(
                exercise: Exercise(
                    id: 0,
                    createdAt: "",
                    updatedAt: "",
                    name: "Tricep Curls",
                    type: "weighted",
                    raw: "3x3 tricep curls - 45 lbs",
                    data: ExerciseData(sets: 3, reps: 3, weight: 45, time: 0, distance: 0)
                )
            )
            
            Divider()
            
            ExerciseView(
                exercise: Exercise(
                    id: 0,
                    createdAt: "",
                    updatedAt: "",
                    name: "Rowing",
                    type: "distance",
                    raw: "rowing 1 miles",
                    data: ExerciseData(sets: 1, reps: 0, weight: 0, time: 0, distance: 1.6)
                )
            )
            
            Divider()
            
            ExerciseView(
                exercise: Exercise(
                    id: 0,
                    createdAt: "",
                    updatedAt: "",
                    name: "Running",
                    type: "distance",
                    raw: "running 4 miles",
                    data: ExerciseData(sets: 1, reps: 0, weight: 0, time: 0, distance: 6.44)
                )
            )
            
            Divider()
        }
    }
}
#endif
