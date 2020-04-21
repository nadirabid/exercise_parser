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
        HStack {
            Text(exercise.name.capitalized)
                .font(.subheadline)
                .foregroundColor(self.valuesColor)
                .shouldItalicize(shouldItalicize)
            
            Spacer()
            
            HStack {
                if exercise.type == "weighted" {
                    VStack(alignment: .trailing, spacing: 1.0) {
                        Text("sets")
                            .font(.caption)
                            .foregroundColor(self.unitsColor)
                            .shouldItalicize(shouldItalicize)
                        
                        Text("\(exercise.weightedExercise!.sets)")
                            .font(.headline)
                            .foregroundColor(self.valuesColor)
                            .shouldItalicize(shouldItalicize)
                    }
                        .padding(.leading, 2.0)
                    
                    VStack(alignment: .trailing, spacing: 1.0) {
                        Text("reps")
                            .font(.caption)
                            .foregroundColor(self.unitsColor)
                            .shouldItalicize(shouldItalicize)
                        
                        Text("\(exercise.weightedExercise!.reps)")
                            .font(.headline)
                            .foregroundColor(self.valuesColor)
                            .shouldItalicize(shouldItalicize)
                    }
                        .padding(.leading, 2.0)
                    
                    VStack(alignment: .trailing, spacing: 1.0) {
                        Text("lbs")
                            .font(.caption)
                            .foregroundColor(self.unitsColor)
                            .shouldItalicize(shouldItalicize)
                        
                        Text(exercise.weightedExercise!.weightInDisplayUnits.format(f: ".0"))
                            .font(.headline)
                            .foregroundColor(self.valuesColor)
                            .shouldItalicize(shouldItalicize)
                    }
                        .padding(.leading, 2.0)
                } else if exercise.type == "distance" {
                    VStack(alignment: .trailing, spacing: 1.0) {
                        Text("mi")
                            .font(.caption)
                            .foregroundColor(self.unitsColor)
                            .shouldItalicize(shouldItalicize)
                        
                        Text(exercise.distanceExercise!.distanceInDisplayUnits.format(f: ".1"))
                            .font(.headline)
                            .foregroundColor(self.valuesColor)
                            .shouldItalicize(shouldItalicize)
                    }
                        .padding(.leading, 2.0)
                    
                    VStack(alignment: .trailing, spacing: 1.0) {
                        Text("time")
                            .font(.caption)
                            .foregroundColor(self.unitsColor)
                            .shouldItalicize(shouldItalicize)
                        
                        Text(secondsToElapsedTimeString(exercise.distanceExercise!.time))
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
            Text("Waiting")
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
            ExerciseView(exercise: Exercise(id: 0, createdAt: "", updatedAt: "", name: "", type: "", raw: "", weightedExercise: nil, distanceExercise: nil))
            ExerciseView(exercise: Exercise(id: 0, createdAt: "", updatedAt: "", name: "", type: "", raw: "", weightedExercise: nil, distanceExercise: nil))
        }
        .environmentObject(MockExerciseAPI(userState: UserState()))
    }
}
#endif
