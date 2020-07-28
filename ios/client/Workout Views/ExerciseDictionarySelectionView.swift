//
//  ExerciseSelectionView.swift
//  client
//
//  Created by Nadir Muzaffar on 7/8/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct ExerciseDictionarySelectionView: View {
    let dictionary: ExerciseDictionary
    @Binding var exerciseTemplates: [ExerciseTemplate]
    
    var onClose: (() -> Void)? = nil
    
    @State private var posteriorTarget: [MuscleActivation] = []
    @State private var posteriorSynergists: [MuscleActivation] = []
    @State private var posteriorDynamic: [MuscleActivation] = []
    
    @State private var anteriorTarget: [MuscleActivation] = []
    @State private var anteriorSynergists: [MuscleActivation] = []
    @State private var anteriorDynamic: [MuscleActivation] = []
    
    @State private var isSetsFieldEnabled: Bool = true
    @State private var isRepsFieldEnabled: Bool = true
    @State private var isTimeFieldEnabled: Bool = false
    @State private var isDistanceFieldEnabled: Bool = false
    @State private var isWeightFieldEnabled: Bool = true
    
    func muscleActiviationsFromFlattened(muscles: [String]?) -> [MuscleActivation]? {
        if muscles == nil {
            return nil
        }
        
        let muscleStrings = muscles!.map { s in s.lowercased() }
        
        return muscleStrings.flatMap { (muscleString) -> [MuscleActivation] in
            if let muscle = Muscle.from(name: muscleString) {
                if muscle.isMuscleGroup {
                    return muscle.components.map { MuscleActivation(muscle: $0) }
                } else {
                    return [MuscleActivation(muscle: muscle)]
                }
            }
            
            return []
        }
    }
    
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
        return
            !isSetsFieldEnabled &&
            !isRepsFieldEnabled &&
            !isTimeFieldEnabled &&
            !isDistanceFieldEnabled &&
            !isWeightFieldEnabled
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
                    activatedTargetMuscles: anteriorTarget,
                    activatedSynergistMuscles: anteriorSynergists,
                    activatedDynamicArticulationMuscles: anteriorDynamic
                )
                
                PosteriorView(
                    activatedTargetMuscles: posteriorTarget,
                    activatedSynergistMuscles: posteriorSynergists,
                    activatedDynamicArticulationMuscles: posteriorDynamic
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
            if let target = self.muscleActiviationsFromFlattened(muscles: self.dictionary.muscles.target) {
                self.posteriorTarget = target.filter({ $0.muscle.orientation == .Posterior })
                self.anteriorTarget = target.filter({ $0.muscle.orientation == .Anterior })
            }
            
            if let synergists = self.muscleActiviationsFromFlattened(muscles: self.dictionary.muscles.synergists) {
                self.posteriorSynergists = synergists.filter({ $0.muscle.orientation == .Posterior })
                self.anteriorSynergists = synergists.filter({ $0.muscle.orientation == .Anterior })
            }
            
            if let dynamic = self.muscleActiviationsFromFlattened(muscles: self.dictionary.muscles.dynamicArticulation) {
                self.posteriorDynamic = dynamic.filter({ $0.muscle.orientation == .Posterior })
                self.anteriorDynamic = dynamic.filter({ $0.muscle.orientation == .Anterior })
            }
        }
    }
}
