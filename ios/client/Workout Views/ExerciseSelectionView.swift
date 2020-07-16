//
//  ExerciseSelectionView.swift
//  client
//
//  Created by Nadir Muzaffar on 7/8/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct ExerciseSelectionView: View {
    let dictionary: ExerciseDictionary
    @Binding var exerciseTemplates: [ExerciseTemplate]
    
    var onClose: (() -> Void)? = nil
    
    @State private var target: [MuscleActivation] = []
    @State private var synergists: [MuscleActivation] = []
    @State private var dynamic: [MuscleActivation] = []
    
    @State private var isSetsFieldEnabled: Bool = true
    @State private var isRepsFieldEnabled: Bool = true
    @State private var isTimeFieldEnabled: Bool = false
    @State private var isDistanceFieldEnabled: Bool = false
    @State private var isWeightFieldEnabled: Bool = true
    
    var title: String {
        let tokens = dictionary.name.split(separator: "(")
        
        return tokens.first!.description
    }
    
    var subTitle: String? {
        let tokens = dictionary.name.split(separator: "(")
        
        if tokens.count > 1 {
            var s = tokens.last!.description
            s.removeLast()
            return s
        }
        
        return nil
    }
    
    var isSelectButtonDisabled: Bool {
        return !isSetsFieldEnabled && !isRepsFieldEnabled && !isTimeFieldEnabled && !isDistanceFieldEnabled && !isWeightFieldEnabled
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading) {
                Text(title).font(.title)
            
                if subTitle != nil {
                    Text(subTitle!).foregroundColor(Color.secondary)
                }
            }
            
            HStack {
                AnteriorView(
                    activatedTargetMuscles: target,
                    activatedSynergistMuscles: synergists,
                    activatedDynamicArticulationMuscles: dynamic
                )
                
                PosteriorView(
                    activatedTargetMuscles: target,
                    activatedSynergistMuscles: synergists,
                    activatedDynamicArticulationMuscles: dynamic
                )
            }
            .frame(height: 280)
            
            VStack(alignment: .leading) {
                Text("Fields").font(.headline)
            
                SelectFieldButtonView(selected: $isSetsFieldEnabled, title: "Sets")
                SelectFieldButtonView(selected: $isRepsFieldEnabled, title: "Reps")
                SelectFieldButtonView(selected: $isWeightFieldEnabled, title: "Weight")
                SelectFieldButtonView(selected: $isTimeFieldEnabled, title: "Time")
                SelectFieldButtonView(selected: $isDistanceFieldEnabled, title: "Distance")
            }
            
            Spacer()
            
            GeometryReader { geometry in
                Button(action: {
                    let template = ExerciseTemplate(
                        data: ExerciseTemplateData(
                            isSetsFieldEnabled: self.isSetsFieldEnabled,
                            isRepsFieldEnabled: self.isRepsFieldEnabled,
                            isWeightFieldEnabled: self.isWeightFieldEnabled,
                            isTimeFieldEnabled: self.isTimeFieldEnabled,
                            isDistanceFieldEnabled: self.isDistanceFieldEnabled
                        ),
                        exerciseDictionaries: [self.dictionary]
                    )
                    
                    self.exerciseTemplates.append(template)
                    
                    if let handleClose = self.onClose {
                        handleClose()
                    }
                }) {
                    Text("Select")
                        .font(.headline)
                        .foregroundColor(Color.white)
                        .padding()
                        .frame(width: geometry.size.width)
                        .background(self.isSelectButtonDisabled ? appColorDisabled : appColor)
                        .cornerRadius(6)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .disabled(self.isSelectButtonDisabled)
        }
        .padding()
        .onAppear {
            if let target = self.dictionary.muscles.target {
                self.target = target.compactMap { Muscle.from(name: $0) }.map { MuscleActivation(muscle: $0) }
            }
            
            if let synergists = self.dictionary.muscles.synergists {
                self.synergists = synergists.compactMap { Muscle.from(name: $0) }.map { MuscleActivation(muscle: $0) }
            }
            
            if let dynamic = self.dictionary.muscles.dynamicArticulation {
                self.dynamic = dynamic.compactMap { Muscle.from(name: $0) }.map { MuscleActivation(muscle: $0) }
            }
        }
    }
}
