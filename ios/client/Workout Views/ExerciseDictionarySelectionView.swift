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
    var onSelect: (() -> Void)? = nil
    
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
    
    @State private var timeUnits: String = "seconds"
    @State private var distanceUnits: String = "feet"
    
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
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(title).font(.title)
                        
                        if subTitle != nil {
                            Text(subTitle!).foregroundColor(Color.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if let handleClose = self.onClose {
                            handleClose()
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(UIColor.systemGray4))
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
                .padding(.bottom)
                
                
                HStack {
                    Text("Display fields").font(.caption).foregroundColor(Color.secondary)
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: { self.isSetsFieldEnabled.toggle() }) {
                        HStack {
                            Text("Sets").foregroundColor(Color.primary)
                            Spacer()
                            Image(systemName: self.isSetsFieldEnabled ? "checkmark.circle.fill" : "circle").foregroundColor(appColor)
                        }
                    }.padding(14)
                    
                    Divider()
                    
                    Button(action: { self.isRepsFieldEnabled.toggle() }) {
                        HStack {
                            Text("Reps").foregroundColor(Color.primary)
                            Spacer()
                            Image(systemName: self.isRepsFieldEnabled ? "checkmark.circle.fill" : "circle").foregroundColor(appColor)
                        }
                    }.padding(14)
                    
                    Divider()
                    
                    Button(action: { self.isWeightFieldEnabled.toggle() }) {
                        HStack {
                            Text("Weight").foregroundColor(Color.primary)
                            Spacer()
                            Image(systemName: self.isWeightFieldEnabled ? "checkmark.circle.fill" : "circle").foregroundColor(appColor)
                        }
                    }.padding(14)
                    
                    Divider()
                    
                    VStack {
                        Button(action: { self.isDistanceFieldEnabled.toggle() }) {
                            HStack {
                                Text("Distance").foregroundColor(Color.primary)
                                Spacer()
                                Image(systemName: self.isDistanceFieldEnabled ? "checkmark.circle.fill" : "circle").foregroundColor(appColor)
                            }
                        }
                        
                        if self.isDistanceFieldEnabled {
                            Picker(selection: self.$distanceUnits, label: Text("Distance units")) {
                                VStack {
                                    Text("Feet")
                                        .fontWeight(.semibold)
                                }.tag("feet")
                                
                                VStack {
                                    Text("Yards")
                                        .fontWeight(.semibold)
                                }.tag("yards")
                                
                                VStack {
                                    Text("Miles")
                                        .fontWeight(.semibold)
                                }.tag("miles")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }.padding(14)
                    
                    Divider()
                    
                    VStack {
                        Button(action: { self.isTimeFieldEnabled.toggle() }) {
                            HStack {
                                Text("Time").foregroundColor(Color.primary)
                                Spacer()
                                Image(systemName: self.isTimeFieldEnabled ? "checkmark.circle.fill" : "circle").foregroundColor(appColor)
                            }
                        }
                        
                        if self.isTimeFieldEnabled {
                            Picker(selection: self.$timeUnits, label: Text("Time units")) {
                                VStack {
                                    Text("Seconds")
                                        .fontWeight(.semibold)
                                }.tag("seconds")
                                
                                VStack {
                                    Text("Minutes")
                                        .fontWeight(.semibold)
                                }.tag("minutes")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }.padding(14)
                }
                .background(Color(UIColor.systemBackground))
                .cornerRadius(8)
                .padding(.bottom)
                .padding(.bottom)
                .padding(.bottom)
                .padding(.bottom)
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                Button(action: {
                    var data = ExerciseTemplateData(
                        isSetsFieldEnabled: self.isSetsFieldEnabled,
                        isRepsFieldEnabled: self.isRepsFieldEnabled,
                        isWeightFieldEnabled: self.isWeightFieldEnabled,
                        isTimeFieldEnabled: self.isTimeFieldEnabled,
                        isDistanceFieldEnabled: self.isDistanceFieldEnabled
                    )
                    
                    data.fieldTimeUnits = self.timeUnits
                    data.fieldDistanceUnits = self.distanceUnits
                    
                    let template = ExerciseTemplate(data: data, exerciseDictionaries: [self.dictionary])
                    
                    self.exerciseTemplates.append(template)
                    
                    if let handleSelect = self.onSelect {
                        handleSelect()
                    }
                }) {
                    HStack {
                        Spacer()
                        
                        Text("Select")
                            .font(.headline)
                            .foregroundColor(Color.white)
                            .padding()
                        
                        Spacer()
                    }
                    .background(self.isSelectButtonDisabled ? appColorDisabled : appColor)
                    .cornerRadius(6)
                }
                .disabled(self.isSelectButtonDisabled)
            }
        }
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

