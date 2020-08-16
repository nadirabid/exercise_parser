//
//  ExerciseCreateFromTemplate.swift
//  client
//
//  Created by Nadir Muzaffar on 7/30/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct ExerciseCreateFromTemplate: View {
    var exerciseTemplate: ExerciseTemplate
    var showCompletionMark: Bool
    var viewWidth: CGFloat
    var onDelete: () -> Void
    var onEdit: () -> Void
    var isEditing: Bool
    
    @EnvironmentObject var exerciseDictionaryAPI: ExerciseDictionaryAPI
    
    @ObservedObject private var dataFields: ExerciseTemplateData
    @State private var activeFields: [ExerciseField] = []
    @State private var showingActionSheet: Bool = false
    
    @State private var posteriorTarget: [MuscleActivation] = []
    @State private var posteriorSynergists: [MuscleActivation] = []
    @State private var posteriorDynamic: [MuscleActivation] = []
    
    @State private var anteriorTarget: [MuscleActivation] = []
    @State private var anteriorSynergists: [MuscleActivation] = []
    @State private var anteriorDynamic: [MuscleActivation] = []
    
    @State private var posteriorTargetWeight: Int = 0
    @State private var posteriorSynergistsWeight: Int = 0
    @State private var posteriorDynamicWeight: Int = 0
    
    @State private var anteriorTargetWeight: Int = 0
    @State private var anteriorSynergistsWeight: Int = 0
    @State private var anteriorDynamicWeight: Int = 0
    
    init(
        exerciseTemplate: ExerciseTemplate,
        showCompletionMark: Bool,
        viewWidth: CGFloat,
        onDelete: @escaping () -> Void = {},
        onEdit: @escaping () -> Void = {},
        isEditing: Bool = true
    ) {
        self.exerciseTemplate = exerciseTemplate
        self.showCompletionMark = showCompletionMark
        self.viewWidth = viewWidth
        self.onDelete = onDelete
        self.dataFields = self.exerciseTemplate.data
        self.onEdit = onEdit
        self.isEditing = isEditing
    }
    
    func loadDictionaries() {
        let ids = Set(exerciseTemplate.exerciseDictionaries.compactMap({ $0.id }))
        
        self.exerciseDictionaryAPI.getListFilteredByIDs(dictionaryIDs: ids).then { r in
            let dictionaries = r.results
            
            // target
            let target = dictionaries.reduce([String]()) { r, d in
                if let target = d.muscles.target {
                    return r + target
                }
                
                return r
            }
            
            if let flattenedTarget = self.muscleActiviationsFromFlattened(muscles: target) {
                self.posteriorTarget = flattenedTarget.filter({ $0.muscle.orientation == .Posterior })
                self.posteriorTargetWeight = self.posteriorTarget.reduce(0) { $0 + $1.muscle.weight }
                
                self.anteriorTarget = flattenedTarget.filter({ $0.muscle.orientation == .Anterior })
                self.anteriorTargetWeight = self.anteriorTarget.reduce(0) { $0 + $1.muscle.weight }
            }
            
            // synergists
            let synergists = dictionaries.reduce([String]()) { r, d in
                if let synergists = d.muscles.synergists {
                    return r + synergists
                }
                
                return r
            }
            
            if let flattenedSynergists = self.muscleActiviationsFromFlattened(muscles: synergists) {
                self.posteriorSynergists = flattenedSynergists.filter({ $0.muscle.orientation == .Posterior })
                self.posteriorSynergistsWeight = self.posteriorSynergists.reduce(0) { $0 + $1.muscle.weight }
                
                self.anteriorSynergists = flattenedSynergists.filter({ $0.muscle.orientation == .Anterior })
                self.anteriorSynergistsWeight = self.anteriorSynergists.reduce(0) { $0 + $1.muscle.weight }
            }
            
            // dynamic
            let dynamic = dictionaries.reduce([String]()) { r, d in
                if let dynamic = d.muscles.dynamicArticulation {
                    return r + dynamic
                }
                
                return r
            }
            
            if let flattenedDynamic = self.muscleActiviationsFromFlattened(muscles: dynamic) {
                self.posteriorDynamic = flattenedDynamic.filter({ $0.muscle.orientation == .Posterior })
                self.posteriorDynamicWeight = self.posteriorDynamic.reduce(0) { $0 + $1.muscle.weight }
                
                self.anteriorDynamic = flattenedDynamic.filter({ $0.muscle.orientation == .Anterior })
                self.anteriorDynamicWeight = self.anteriorDynamic.reduce(0) { $0 + $1.muscle.weight }
            }
        }
    }
    
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
    
    func calculateWidthFor(field: ExerciseField) -> CGFloat {
        let c = self.dataFields.isSetsFieldEnabled ? 1 : 2
        return (viewWidth) / CGFloat(activeFields.count + c) // TODO: this is fucked
    }
    
    func createFakeColumnViewFor(field: ExerciseField) -> some View {
        return HStack(alignment: .center) {
            if field == activeFields.last {
                Spacer()
            }
            
            if field == .sets {
                Text("\(self.dataFields.sets + 1)")
                    .font(Font.system(size: 12).italic().weight(.ultraLight))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color.secondary)
                
                Spacer()
            } else {
                VStack(alignment: .trailing, spacing: 0) {
                    createFakeTextFieldFor(field: field)
                        .font(Font.title.italic().weight(.ultraLight))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                    
                    if field == .time {
                        Text(self.dataFields.fieldTimeUnits.lowercased())
                            .font(.system(size: 10))
                            .foregroundColor(Color.secondary)
                            .padding(.top, -4)
                    } else if field == .distance {
                        Text(self.dataFields.fieldDistanceUnits.lowercased())
                            .font(.system(size: 10))
                            .foregroundColor(Color.secondary)
                            .padding(.top, -4)
                    } else if field == .weight {
                        Text(self.dataFields.fieldWeightUnits.lowercased())
                            .font(.system(size: 10))
                            .foregroundColor(Color.secondary)
                            .padding(.top, -4)
                    } else {
                        Text(field.description)
                            .font(.system(size: 10))
                            .foregroundColor(Color.secondary)
                            .padding(.top, -4)
                    }
                }
            }
        }
        .frame(width: field == .sets ? nil : calculateWidthFor(field: field))
    }
    
    func createFakeTextFieldFor(field: ExerciseField) -> some View {
        if field == .reps {
            let b = Binding<String>(
                get: { () -> String in
                    "\(self.dataFields.defaultValueReps)"
            },
                set: { (value) in }
            )
            
            return TextField("0", text: b)
        } else if field == .weight {
            let b = Binding<String>(
                get: { () -> String in
                    "\(self.dataFields.defaultValueWeight.format(f: ".0"))"
            },
                set: { (value) in }
            )
            
            return TextField("0", text: b)
        } else if field == .distance {
            let b = Binding<String>(
                get: { () -> String in
                    "\(self.dataFields.defaultValueDistance.format(f: ".0"))"
            },
                set: { (value) in }
            )
            
            return TextField("0", text: b)
        } else {
            let b = Binding<String>(
                get: { () -> String in
                    "\(self.dataFields.defaultValueTime)"
            },
                set: { (value) in }
            )
            
            return TextField("0", text: b)
        }
    }
    
    func createColumnViewFor(field: ExerciseField, _ itemSetIndex: Int) -> some View {
        HStack(alignment: .center) {
            if field == .sets {
                Text("\(itemSetIndex + 1)")
                    .font(.system(size: 12))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color.secondary)
                
                Spacer()
            } else {
                VStack(alignment: .trailing, spacing: 0) {
                    createTextFieldFor(field: field, itemSetIndex: itemSetIndex)
                        .font(Font.title.weight(.light))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                    
                    if field == .time {
                        Text(self.dataFields.fieldTimeUnits.lowercased())
                            .font(.system(size: 10))
                            .foregroundColor(Color.secondary)
                            .padding(.top, -4)
                    } else if field == .distance {
                        Text(self.dataFields.fieldDistanceUnits.lowercased())
                            .font(.system(size: 10))
                            .foregroundColor(Color.secondary)
                            .padding(.top, -4)
                    } else if field == .weight {
                        Text(self.dataFields.fieldWeightUnits.lowercased())
                            .font(.system(size: 10))
                            .foregroundColor(Color.secondary)
                            .padding(.top, -4)
                    } else {
                        Text(field.description)
                            .font(.system(size: 10))
                            .foregroundColor(Color.secondary)
                            .padding(.top, -4)
                    }
                }
            }
        }
        .frame(width: field == .sets ? nil : calculateWidthFor(field: field))
    }
    
    func createTextFieldFor(field: ExerciseField, itemSetIndex: Int) -> some View {
        if field == .reps {
            let b = Binding<String>(
                get: { () -> String in
                    "\(self.dataFields.reps[itemSetIndex])"
            },
                set: { (value) in
                    self.dataFields.reps = self.dataFields.reps.map { $0 }
                    
                    if let v = Int(value) {
                        self.dataFields.reps[itemSetIndex] = v
                    }
            }
            )
            
            return TextField("0", text: b)
        } else if field == .weight {
            let b = Binding<String>(
                get: { () -> String in
                    "\(self.dataFields.weight[itemSetIndex].format(f: ".0"))"
            },
                set: { (value) in
                    self.dataFields.weight = self.dataFields.weight.map { $0 }
                    
                    if let v = Float(value) {
                        self.dataFields.weight[itemSetIndex] = v
                    }
            }
            )
            
            return TextField("0", text: b)
        } else if field == .distance {
            let b = Binding<String>(
                get: { () -> String in
                    "\(self.dataFields.distance[itemSetIndex].format(f: ".0"))"
            },
                set: { (value) in
                    self.dataFields.distance = self.dataFields.distance.map { $0 }
                    
                    if let v = Float(value) {
                        self.dataFields.distance[itemSetIndex] = v
                    }
            }
            )
            
            return TextField("0", text: b)
        } else {
            let b = Binding<String>(
                get: { () -> String in
                    "\(self.dataFields.time[itemSetIndex])"
                },
                set: { (value) in
                    self.dataFields.time = self.dataFields.time.map { $0 }
                    
                    if let v = Int(value) {
                        self.dataFields.time[itemSetIndex] = v
                    }
                }
            )
            
            return TextField("0", text: b)
        }
    }
    
    var timeUnits: String {
        let units = self.dataFields.fieldTimeUnits.lowercased()
        
        switch units {
        case "seconds":
            return "sec"
        case "minutes":
            return "min"
        default:
            return self.dataFields.fieldTimeUnits
        }
    }
    
    var distanceUnits: String {
        switch self.dataFields.fieldDistanceUnits.lowercased() {
        case "feet":
            return "ft"
        case "yards":
            return "yd"
        case "miles":
            return "mi"
        default:
            return self.dataFields.fieldDistanceUnits
        }
    }
    
    var exerciseFont: Font {
        .system(size: 20, weight: .medium)
    }
    
    var infoFont: Font {
        .system(size: 18)
    }
    
    var dictionary: ExerciseDictionary {
        // technically we allow for multiple exercise dictionaries for a given activity
        // but right now for routine based workouts we will assume only one exercise dictionary
        return exerciseTemplate.exerciseDictionaries.first!
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
    
    var orientationToShow: AnatomicalOrientation? {
        if anteriorTargetWeight != 0 || posteriorTargetWeight != 0 {
            if anteriorTargetWeight > posteriorTargetWeight {
                return .Anterior
            } else {
                return .Posterior
            }
        }
        
        if anteriorDynamicWeight != 0 || posteriorDynamicWeight != 0 {
            if anteriorDynamicWeight > posteriorDynamicWeight {
                return .Anterior
            } else {
                return .Posterior
            }
        }
        
        if anteriorSynergistsWeight != 0 || posteriorDynamicWeight != 0 {
            if anteriorSynergistsWeight > posteriorSynergistsWeight {
                return .Anterior
            } else {
                return .Posterior
            }
        }
        
        return nil
    }
    
    var fade: Gradient {
        Gradient(colors: [Color.clear, Color.black, Color.black, Color.black, Color.black, Color.clear])
    }
    
    var body: some View {
        return HStack(spacing: 0) {
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    if self.isEditing {
                        Button(action: { self.onDelete() }) {
                            Image(systemName: "trash.circle.fill")
                                .foregroundColor(appColor)
                                .font(.system(size: 26))
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text(self.title).fontWeight(.semibold)
                        
                        if self.subTitle != nil {
                            Text("(\(self.subTitle!))")
                                .font(.caption)
                                .foregroundColor(Color.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if orientationToShow == .Anterior {
                        FocusedAnteriorView(
                            activatedTargetMuscles: anteriorTarget,
                            activatedSynergistMuscles: anteriorSynergists,
                            activatedDynamicArticulationMuscles: anteriorDynamic
                        )
                            .padding(.all, 6)
                            .frame(width: 25, height: 45)
                            .clipShape(Rectangle())
                            .mask(LinearGradient(gradient: fade, startPoint: .bottom, endPoint: .top))
                            .mask(LinearGradient(gradient: fade, startPoint: .leading, endPoint: .trailing))
                    } else if orientationToShow == .Posterior {
                        FocusedPosteriorView(
                            activatedTargetMuscles: self.posteriorTarget,
                            activatedSynergistMuscles: self.posteriorSynergists,
                            activatedDynamicArticulationMuscles: self.posteriorDynamic
                        )
                            .padding(.all, 6)
                            .frame(width: 25, height: 45)
                            .clipShape(Rectangle())
                            .mask(LinearGradient(gradient: fade, startPoint: .bottom, endPoint: .top))
                            .mask(LinearGradient(gradient: fade, startPoint: .leading, endPoint: .trailing))
                    } else {
                        Rectangle().fill(Color.clear).frame(width: 25, height: 40)
                    }
                    
                    Button(action: { self.onEdit() }) {
                        if self.isEditing {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(appColor)
                                .font(Font.system(size: 16))
                        } else {
                            Image(systemName: "pencil.circle")
                                .foregroundColor(Color(UIColor.systemGray4))
                                .font(Font.system(size: 16))
                        }
                    }
                }
                
                VStack(spacing: 0) {
                    ForEach(0..<self.dataFields.sets, id:\.self) { itemSetIndex in
                        HStack(alignment: .center, spacing: 0) {
                            if !self.dataFields.isSetsFieldEnabled {
                                Spacer()
                            }
                            
                            ForEach(self.activeFields, id: \.self) { item in
                                self.createColumnViewFor(field: item, itemSetIndex)
                            }
                            .disabled(self.isEditing)
                            .opacity(self.isEditing ? 0.4 : 1)
                            
                            HStack(spacing: 0) {
                                if !self.isEditing {
                                    if self.showCompletionMark {
                                        Button(action: {
                                            var complete = self.dataFields.completedSets.compactMap { $0 }
                                            complete[itemSetIndex] = !complete[itemSetIndex]
                                            self.dataFields.completedSets = complete
                                        }) {
                                            HStack(alignment: .center) {
                                                if self.dataFields.completedSets[itemSetIndex] {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(appColor)
                                                        .font(.system(size: 16))
                                                } else {
                                                    Image(systemName: "checkmark.circle")
                                                        .foregroundColor(Color(UIColor.systemGray4))
                                                        .font(.system(size: 16))
                                                }
                                            }
                                        }
                                    } else {
                                        Image(systemName: "checkmark.circle")
                                            .foregroundColor(Color.clear)
                                            .font(.system(size: 16))
                                    }
                                } else if self.dataFields.isSetsFieldEnabled {
                                    Button(action: {
                                        self.dataFields.removeSetAt(index: itemSetIndex)
                                    }) {
                                        Image(systemName: "minus.circle")
                                            .foregroundColor(appColor)
                                            .font(.system(size: 16))
                                    }
                                } else {
                                    Image(systemName: "checkmark.circle")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.clear)
                                }
                            }
                            .padding(.leading)
                        }
                        .padding(.top, 6)
                    }
                    
                    if self.dataFields.isSetsFieldEnabled && self.isEditing {
                        HStack(alignment: .center, spacing: 0) {
                            ForEach(self.activeFields, id: \.self) { item in
                                self.createFakeColumnViewFor(field: item)
                            }
                            .disabled(true)
                            .opacity(0.4)
                            
                            Button(action: {
                                withAnimation {
                                    self.dataFields.addSet()
                                }
                            }) {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(appColor)
                                    .font(.system(size: 16))
                            }
                            .padding(.leading)
                        }
                        .padding(.top, 6)
                    }
                }
            }
            .padding(.all)
        }
        .onAppear {
            self.activeFields = [.sets, .reps, .weight, .distance, .time].filter {
                self.exerciseTemplate.data.isActive(field: $0)
            }
            
            self.loadDictionaries()
        }
    }
}
