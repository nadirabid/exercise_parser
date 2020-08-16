//
//  WorkoutTemplateView.swift
//  client
//
//  Created by Nadir Muzaffar on 6/25/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct WorkoutTemplateView: View {
    @EnvironmentObject var userAPI: UserAPI
    @EnvironmentObject var routeState: RouteState
    @EnvironmentObject var workoutTemplateAPI: WorkoutTemplateAPI
    @EnvironmentObject var exerciseDictionaryAPI: ExerciseDictionaryAPI
    
    var template: WorkoutTemplate
    var onDelete: () -> Void = {}
    var onEdit: () -> Void = {}
    
    var options = [ "waveform.path.ecg", "function" ]
    
    @State private var view = "waveform.path.ecg"
    @State private var showingActionSheet = false
    
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
    
    func loadDictionaries() {
        let ids = Set(self.template.exercises.reduce([Int]()) { r, t in
            r + t.exerciseDictionaries.compactMap({ $0.id })
        })
        
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
    
    func shouldShowRoundsBeforeExercise(_ exercise: Exercise) -> Bool {
        let firstExerciseOfCircuitID = exercisesToDisplay.first(where: { $0.circuitID == exercise.circuitID })
        if exercise.circuitID != nil && firstExerciseOfCircuitID != nil && exercise.id == firstExerciseOfCircuitID!.id {
            return true
        }
        
        return false
    }
    
    var dictionary: ExerciseDictionary {
        return self.template.exercises.first!.exerciseDictionaries.first!
    }
    
    var exercisesToDisplay: [ExerciseTemplate] {
        return template.exercises.sorted(by: { $0.id! < $1.id! })
    }
    
    var templateName: String {
        if template.name.isEmpty {
            return "Unnamed"
        }
        
        return template.name
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
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text(templateName)
                        .fontWeight(.semibold)
                    
                    WorkoutTemplateMetaMetricsView(workoutTemplate: self.template)
                        .fixedSize(horizontal: true, vertical: true)
                }
                
                Spacer()
                
                if orientationToShow == .Anterior {
                    FocusedAnteriorView(
                        activatedTargetMuscles: anteriorTarget,
                        activatedSynergistMuscles: anteriorSynergists,
                        activatedDynamicArticulationMuscles: anteriorDynamic
                    )
                        .padding(.all, 8)
                        .frame(width: 60, height: 90)
                        .clipShape(Rectangle())
                        .mask(LinearGradient(gradient: fade, startPoint: .bottom, endPoint: .top))
                        .mask(LinearGradient(gradient: fade, startPoint: .leading, endPoint: .trailing))
                } else if orientationToShow == .Posterior {
                    FocusedPosteriorView(
                        activatedTargetMuscles: self.posteriorTarget,
                        activatedSynergistMuscles: self.posteriorSynergists,
                        activatedDynamicArticulationMuscles: self.posteriorDynamic
                    )
                        .padding(.all, 8)
                        .frame(width: 60, height: 90)
                        .clipShape(Rectangle())
                        .mask(LinearGradient(gradient: fade, startPoint: .bottom, endPoint: .top))
                        .mask(LinearGradient(gradient: fade, startPoint: .leading, endPoint: .trailing))
                } else {
                    Rectangle().fill(Color.clear).frame(width: 60, height: 90)
                }
            }
        }
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(title: Text(self.template.name), buttons: [
                .default(Text("Edit")) { self.onEdit() },
                .destructive(Text("Delete")) { self.onDelete() },
                .cancel()
            ])
        }
        .onAppear {
            self.loadDictionaries()
        }
    }
}

public struct WorkoutTemplateMetaMetricsView: View {
    @State var workoutTemplate: WorkoutTemplate
    
    var totalWeight: Int {
        let result = workoutTemplate.exercises.reduce(Float.zero) { (r, e) in
            let circuitRounds = Float(e.circuitRounds > 1 ? e.circuitRounds : 1)
            let total = (0..<e.data.sets).reduce(Float.zero) { (result, i) in
                return circuitRounds * Float(e.data.reps[i]) * e.data.weight[i]
            }
            
            return total + r
        }
        
        return Int(round(result))
    }
    
    var totalDistanceUnits: String {
        let result = workoutTemplate.exercises.reduce(Float.zero) { (r, e) in
            let circuitRounds = Float(e.circuitRounds > 1 ? e.circuitRounds : 1)
            let total = (0..<e.data.sets).reduce(Float.zero) { (result, i) in
                return circuitRounds * Float(e.data.reps[i]) * e.data.distance[i]
            }
            return r + total
        }
        
        if result <= 300 {
            return UnitLength.feet.symbol
        }
        
        return UnitLength.miles.symbol
    }
    
    var totalDistance: Float {
        let result = workoutTemplate.exercises.reduce(Float.zero) { (r, e) in
            let circuitRounds = Float(e.circuitRounds > 1 ? e.circuitRounds : 1)
            let total = (0..<e.data.sets).reduce(Float.zero) { (result, i) in
                return circuitRounds * Float(e.data.reps[i]) * e.data.distance[i]
            }
            return r + total
        }
        
        var m = Measurement(value: Double(result), unit: UnitLength.meters)
        
        if result <= 300 {
            m = m.converted(to: UnitLength.feet)
        } else {
            m = m.converted(to: UnitLength.miles)
        }
        
        return Float(round(m.value*10)/10)
    }
    
    var totalReps: Int {
        let result = workoutTemplate.exercises.reduce(Int.zero) { (r, e) in
            let circuitRounds = e.circuitRounds > 1 ? e.circuitRounds : 1
            
            let total = (0..<e.data.sets).reduce(Int.zero) { (result, i) in
                if e.data.reps[i] <= 1 { // if reps is 1 or less - we're not going to show the count
                    return 0
                } else {
                    return e.data.reps[i] * circuitRounds
                }
            }
            
            return r + total
        }
        
        return result
    }
    
    var totalSets: Int {
        let result = workoutTemplate.exercises.reduce(Int.zero) { (r, e) in
            if e.data.sets <= 1 {
                return r
            }
            
            let circuitRounds = e.circuitRounds > 1 ? e.circuitRounds : 1
            return r + e.data.sets * circuitRounds
        }
        
        return result
    }
    
    var time: Int {
        return workoutTemplate.exercises.reduce(0) { (result, exerciseTemplate) in
            let total = (0..<exerciseTemplate.data.sets).reduce(0) { (result, i) in
                result + exerciseTemplate.data.time[i]
            }
            
            return result + total
        }
    }
    
    public var body: some View {
        HStack(spacing: 10) {
            WorkoutDetail(name: "Sets", value:"\(totalSets.description)")
        
            Divider()
            
            WorkoutDetail(name: "Reps", value:"\(totalReps.description)")
            
            if totalDistance > 0 {
                Divider()
                
                WorkoutDetail(name: "Distance", value: "\(totalDistance) \(totalDistanceUnits)")
            }
        }
    }
}

struct WorkoutTemplateMusclesMetricsView: View {
    let template: WorkoutTemplate
    
    @EnvironmentObject var exerciseDictionaryAPI: ExerciseDictionaryAPI
    
    @State private var posteriorTarget: [MuscleActivation] = []
    @State private var posteriorSynergists: [MuscleActivation] = []
    @State private var posteriorDynamic: [MuscleActivation] = []
    
    @State private var anteriorTarget: [MuscleActivation] = []
    @State private var anteriorSynergists: [MuscleActivation] = []
    @State private var anteriorDynamic: [MuscleActivation] = []
    
    func loadDictionaries() {
        let ids = Set(self.template.exercises.reduce([Int]()) { r, t in
            r + t.exerciseDictionaries.compactMap({ $0.id })
        })
        
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
                self.anteriorTarget = flattenedTarget.filter({ $0.muscle.orientation == .Anterior })
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
                self.anteriorSynergists = flattenedSynergists.filter({ $0.muscle.orientation == .Anterior })
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
                self.anteriorDynamic = flattenedDynamic.filter({ $0.muscle.orientation == .Anterior })
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
    
    var body: some View {
        return VStack {
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
        }
        .onAppear {
            self.loadDictionaries()
        }
    }
}
