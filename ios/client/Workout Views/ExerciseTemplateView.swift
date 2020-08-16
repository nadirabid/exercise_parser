//
//  ExerciseTemplateView.swift
//  client
//
//  Created by Nadir Muzaffar on 7/16/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct ExerciseTemplateView: View {
    var exerciseTemplate: ExerciseTemplate
    
    var labelFont: Font {
        .system(size: 9)
    }
    
    var title: String {
        let tokens = exerciseTemplate.exerciseDictionaries.first!.name.split(separator: "(")
        
        return tokens.first!.description
    }
    
    var subTitle: String? {
        let tokens = exerciseTemplate.exerciseDictionaries.first!.name.split(separator: "(")
        
        if tokens.count > 1 {
            var s = tokens.last!.description
            s.removeLast()
            return s
        }
        
        return nil
    }
    
    var showReps: Bool {
        if !exerciseTemplate.data.isRepsFieldEnabled || exerciseTemplate.data.reps.contains(where: { $0 != exerciseTemplate.data.reps.first! }) {
            return false
        }
        
        return true
    }
    
    var showWeight: Bool {
        if !exerciseTemplate.data.isWeightFieldEnabled || exerciseTemplate.data.weight.contains(where: { $0 != exerciseTemplate.data.weight.first! }) {
            return false
        }
        
        return true
    }
    
    var showDistance: Bool {
        if !exerciseTemplate.data.isDistanceFieldEnabled || exerciseTemplate.data.distance.contains(where: { $0 != exerciseTemplate.data.distance.first! }) {
            return false
        }
        
        return true
    }
    
    var showTime: Bool {
        if !exerciseTemplate.data.isTimeFieldEnabled || exerciseTemplate.data.time.contains(where: { $0 != exerciseTemplate.data.time.first! }) {
            return false
        }
        
        return true
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                Text(title).font(.subheadline)
                
                if subTitle != nil {
                    Text(" - \(subTitle!)")
                        .font(.caption)
                        .foregroundColor(Color.secondary)
                }
            }
            
            HStack(spacing: 8) {
                if exerciseTemplate.data.isSetsFieldEnabled {
                    HStack(spacing: 0) {
                        Text("sets / ".uppercased())
                            .font(labelFont)
                            .foregroundColor(Color.secondary)
                            .fixedSize()
                        
                        Text("5")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .fixedSize()
                    }
                }
                
                if showReps {
                    HStack(spacing: 0) {
                        Text("reps / ".uppercased())
                            .font(labelFont)
                            .foregroundColor(Color.secondary)
                            .fixedSize()
                        
                        Text("\(exerciseTemplate.data.reps.first ?? 0)")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .fixedSize()
                    }
                }
                
                if showWeight {
                    HStack(spacing: 0) {
                        Text("\(exerciseTemplate.data.fieldWeightUnits) / ".uppercased())
                            .font(labelFont)
                            .foregroundColor(Color.secondary)
                            .fixedSize()
                        
                        Text("\(exerciseTemplate.data.displayWeightValue(setIndex: 0).format(f: ".0"))")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .fixedSize()
                    }
                }
                
                if showDistance {
                    HStack(spacing: 0) {
                        Text("\(exerciseTemplate.data.fieldDistanceUnits) / ".uppercased())
                            .font(labelFont)
                            .foregroundColor(Color.secondary)
                            .fixedSize()
                        
                        Text("\(exerciseTemplate.data.displayDistanceValue(setIndex: 0))")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .fixedSize()
                    }
                }
                
                if showTime {
                    HStack(spacing: 0) {
                        Text("time / ".uppercased())
                            .font(labelFont)
                            .foregroundColor(Color.secondary)
                            .fixedSize()
                        
                        Text(secondsToElapsedTimeString(exerciseTemplate.data.time.first ?? 0))
                            .font(.callout)
                            .fontWeight(.semibold)
                            .fixedSize()
                    }
                }
                
                Spacer()
            }
        }
    }
}
