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
    
    var shouldShowRestIcon: Bool {
        return exercise.resolutionType == ExerciseResolutionType.AutoSpecialRestResolutionType.rawValue
    }
    
    var valueFont: Font {
        switch displayType {
        case .primary:
            return Font.system(size: 15)
        case .secondary, .tertiary:
            return .footnote
        }
    }
    
    var body: some View {
        HStack {
            Text(exercise.name.capitalized)
                .font(.subheadline)
                .foregroundColor(self.valuesColor)
                .shouldItalicize(shouldItalicize)
            
            if shouldShowRestIcon {
                Image(systemName: "wind")
                    .padding(.trailing)
                    .foregroundColor(Color.secondary)
                    .font(.caption)
            }
            
            Spacer()
            
            HStack {
                if exercise.data.time > 0 {
                    VStack(alignment: .trailing, spacing: 1.0) {
                        Text("time")
                            .font(.caption)
                            .foregroundColor(self.unitsColor)
                            .shouldItalicize(shouldItalicize)
                        
                        Text(secondsToElapsedTimeString(exercise.data.time))
                            .font(valueFont)
                            .fontWeight(.semibold)
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
                        
                        Text(exercise.data.displayDistanceValue.description)
                            .font(valueFont)
                            .fontWeight(.semibold)
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
                            .font(valueFont)
                            .fontWeight(.semibold)
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
                            .font(valueFont)
                            .fontWeight(.semibold)
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
                            .font(valueFont)
                            .fontWeight(.semibold)
                            .foregroundColor(self.valuesColor)
                            .shouldItalicize(shouldItalicize)
                    }
                    .padding(.leading, 2.0)
                }
            }
        }
    }
}

struct CorrectiveExerciseView: View {
    var exercise: Exercise
    var showRawString: Bool = true
    
    var correctiveMessage: String {
        return ExerciseCorrectiveCode.from(code: exercise.correctiveCode).message
    }
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                if showRawString {
                    Text(exercise.raw)
                        .font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "exclamationmark.circle")
                        .padding(.all, 0)
                        .foregroundColor(Color.secondary)
                        .font(.caption)
                    
                    Text(correctiveMessage)
                        .font(.caption)
                        .foregroundColor(Color.secondary)
                }
            }
            
            Spacer()
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
                    .foregroundColor(Color.secondary)
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
