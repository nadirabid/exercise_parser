//
//  ExerciseDictionaryListView.swift
//  client
//
//  Created by Nadir Muzaffar on 7/8/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI
import ASCollectionView

struct ExerciseDictionaryListView: View {
    @EnvironmentObject var dictionariesAPI: ExerciseDictionaryAPI
    
    var onSelectExerciseTemplates: (([ExerciseTemplate]) -> Void)? = nil
    var onClose: (() -> Void)? = nil
    
    @State private var allDictionaries: [ExerciseDictionary] = []
    @State private var allDictionariesByID: [Int:ExerciseDictionary] = [Int:ExerciseDictionary]()
    @State private var filteredDictionaryIDs: [Int] = []
    
    @State private var exerciseSelectionPreview: ExerciseDictionary? = nil
    @State private var exerciseTemplates: [ExerciseTemplate] = []
    
    @State private var searchTerms = ""
    
    func isSelected(exerciseDictionary: ExerciseDictionary) -> Bool {
        return self.exerciseTemplates.contains(where: { $0.exerciseDictionaries.contains(where: { $0.id == exerciseDictionary.id }) })
    }
    
    var filteredDictionaries: [ExerciseDictionary] {
        if filteredDictionaryIDs.isEmpty || allDictionaries.isEmpty {
            return allDictionaries
        }
        
        // TODO: this approach is dangerious as filteredDictionariesIDs could include IDs
        // that are not pressent in allDictionaries - do it the other way around
        
        return self.filteredDictionaryIDs.map { allDictionariesByID[$0]! }
    }
    
    var userSearchTerm: Binding<String> {
        return Binding<String>(
            get: {
                self.searchTerms
            },
            set: { v in
                self.searchTerms = v
                
                if v.isEmpty {
                    self.filteredDictionaryIDs = []
                    return
                }
                
                self.dictionariesAPI.getDictionarySearchLite(query: self.searchTerms)
                    .then { (result) in
                        if self.searchTerms == v && result.results.count > 0 {
                            self.filteredDictionaryIDs = result.results
                        } else if self.searchTerms == v {
                            self.filteredDictionaryIDs = []
                        }
                }
            }
        )
    }
    
    var body: some View {
        UITableView.appearance().separatorColor = .systemGray
        UITableView.appearance().backgroundColor = feedColor.uiColor()
        UITableView.appearance().showsVerticalScrollIndicator = false
        
        return ZStack {
            VStack {
                HStack {
                    Button(action: {
                        if let handleClose = self.onClose {
                            handleClose()
                        }
                    }) {
                        Text("Close")
                    }
                    
                    Spacer()
                }
                .padding(.leading)
                
                SearchBarView(searchText: self.userSearchTerm)
            
                ASCollectionView(data: self.filteredDictionaries, dataID: \.id) { item, _ in
                    VStack {
                        Button(action: {
                            self.exerciseSelectionPreview = item
                        }) {
                            ExerciseDictionaryListItem(dictionary: item, isSelected: self.isSelected(exerciseDictionary: item))
                                .background(Color(UIColor.systemBackground))
                                .padding([.leading, .trailing])
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                    }
                    .frame(minHeight: 110, maxHeight: 110)
                }
                .onAppear {
                    self.dictionariesAPI.getDictionaryList().then(on: DispatchQueue.main) { (paginatedResponse: PaginatedResponse<ExerciseDictionary>) in
                        let dictionaries = paginatedResponse.results
                        
                        self.allDictionaries = dictionaries
                        self.allDictionariesByID = Dictionary(uniqueKeysWithValues: dictionaries.map { ($0.id!, $0) })
                    }
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            
            if self.exerciseSelectionPreview != nil {
                VStack {
                    HStack {
                        Button(action: { self.exerciseSelectionPreview = nil }) {
                            Image(systemName: "chevron.left")
                                .font(Font.title.weight(.medium))
                            Text("Back")
                        }
                        
                        Spacer()
                    }
                    .padding(.leading)
                    
                    ExerciseDictionarySelectionView(
                        dictionary: self.exerciseSelectionPreview!,
                        exerciseTemplates: self.$exerciseTemplates
                    ) {
                        if let handleSelect = self.onSelectExerciseTemplates {
                            handleSelect(self.exerciseTemplates)
                        }
                        
                        self.exerciseSelectionPreview = nil
                    }
                        .padding(.bottom)
                        .padding(.bottom)
                }
                .background(Color(UIColor.systemBackground))
                .edgesIgnoringSafeArea(.bottom)
            }
        }
    }
}

struct ExerciseDictionaryListItem: View {
    let dictionary: ExerciseDictionary
    let isSelected: Bool
    
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
    
    var mainTitle: String {
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

    var body: some View {
        return HStack {
            VStack(alignment: .leading) {
                Text(mainTitle).font(.callout).foregroundColor(isSelected ? appColor : Color.primary).fontWeight(isSelected ? .semibold : .regular)
                
                if subTitle != nil {
                    Text(subTitle!).font(.caption).foregroundColor(Color.secondary)
                }
            }
            
            Spacer()
            
            if orientationToShow == .Anterior {
                FocusedAnteriorView(
                    activatedTargetMuscles: self.anteriorTarget,
                    activatedSynergistMuscles: self.anteriorSynergists,
                    activatedDynamicArticulationMuscles: self.anteriorDynamic
                )
                    .padding()
                    .frame(width: 80, height: 90)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(appColor, lineWidth: 1))
            } else if orientationToShow == .Posterior {
                FocusedPosteriorView(
                    activatedTargetMuscles: self.posteriorTarget,
                    activatedSynergistMuscles: self.posteriorSynergists,
                    activatedDynamicArticulationMuscles: self.posteriorDynamic
                )
                    .padding()
                    .frame(width: 80, height: 90)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(appColor, lineWidth: 1))
            } else {
                Circle().fill(Color.clear).frame(width: 80, height: 80)
            }
        }
        .onAppear {
            if let target = self.muscleActiviationsFromFlattened(muscles: self.dictionary.muscles.target) {
                // posterior
                self.posteriorTarget = target.filter({ $0.muscle.orientation == .Posterior })
                self.posteriorTargetWeight = self.posteriorTarget.reduce(0) { $0 + $1.muscle.weight }

                // anterior
                self.anteriorTarget = target.filter({ $0.muscle.orientation == .Anterior })
                self.anteriorTargetWeight = self.anteriorTarget.reduce(0) { $0 + $1.muscle.weight }
            }

            if let synergists = self.muscleActiviationsFromFlattened(muscles: self.dictionary.muscles.synergists) {
                // posterior
                self.posteriorSynergists = synergists.filter({ $0.muscle.orientation == .Posterior })
                self.posteriorSynergistsWeight = self.posteriorSynergists.reduce(0) { $0 + $1.muscle.weight }

                // anterior
                self.anteriorSynergists = synergists.filter({ $0.muscle.orientation == .Anterior })
                self.anteriorSynergistsWeight = self.anteriorSynergists.reduce(0) { $0 + $1.muscle.weight }
            }
            
            if let dynamic = self.muscleActiviationsFromFlattened(muscles: self.dictionary.muscles.dynamicArticulation) {
                // posterior
                self.posteriorDynamic = dynamic.filter({ $0.muscle.orientation == .Posterior })
                self.posteriorDynamicWeight = self.posteriorDynamic.reduce(0) { $0 + $1.muscle.weight }
                
                // anterior
                self.anteriorDynamic = dynamic.filter({ $0.muscle.orientation == .Anterior })
                self.anteriorDynamicWeight = self.anteriorDynamic.reduce(0) { $0 + $1.muscle.weight }
            }
        }
    }
}

struct ExerciseDictionaryListView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseDictionaryListView()
    }
}
