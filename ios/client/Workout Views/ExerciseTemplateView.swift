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
                
                if exerciseTemplate.data.isRepsFieldEnabled {
                    HStack(spacing: 0) {
                        Text("reps / ".uppercased())
                            .font(labelFont)
                            .foregroundColor(Color.secondary)
                            .fixedSize()
                        
                        Text("9")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .fixedSize()
                    }
                }
                
                if exerciseTemplate.data.isWeightFieldEnabled {
                    HStack(spacing: 0) {
                        Text("lbs / ".uppercased())
                            .font(labelFont)
                            .foregroundColor(Color.secondary)
                            .fixedSize()
                        
                        Text("135")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .fixedSize()
                    }
                }
                
                if exerciseTemplate.data.isDistanceFieldEnabled {
                    HStack(spacing: 0) {
                        Text("mi / ".uppercased())
                            .font(labelFont)
                            .foregroundColor(Color.secondary)
                            .fixedSize()
                        
                        Text("2")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .fixedSize()
                    }
                }
                
                if exerciseTemplate.data.isTimeFieldEnabled {
                    HStack(spacing: 0) {
                        Text("time / ".uppercased())
                            .font(labelFont)
                            .foregroundColor(Color.secondary)
                            .fixedSize()
                        
                        Text("30s")
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
