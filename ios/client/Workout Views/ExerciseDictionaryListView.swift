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
    
    var onSelectExerciseDictionary: ((ExerciseDictionary) -> Void)? = nil
    var onClose: (() -> Void)? = nil
    
    @State private var allDictionaries: [ExerciseDictionary] = []
    @State private var allDictionariesByID: [Int:ExerciseDictionary] = [Int:ExerciseDictionary]()
    @State private var filteredDictionaryIDs: [Int] = []
    
    @State private var exerciseSelectionPreview: ExerciseDictionary? = nil
    @State private var exercises: [ExerciseTemplate] = []
    
    @State private var searchTerms = ""
    
    func isSelected(exerciseDictionary: ExerciseDictionary) -> Bool {
        return self.exercises.contains(where: { $0.exerciseDictionaries.contains(where: { $0.id == exerciseDictionary.id }) })
    }
    
    var filteredDictionaries: [ExerciseDictionary] {
        if filteredDictionaryIDs.isEmpty {
            return allDictionaries
        }
        
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
                SearchBarView(searchText: self.userSearchTerm)
            
                ASTableView(data: self.filteredDictionaries, dataID: \.id) { item, _ in
                    Button(action: {
                        self.exerciseSelectionPreview = item
                    }) {
                        ExerciseListItem(dictionary: item, isSelected: self.isSelected(exerciseDictionary: item))
                            .background(Color(UIColor.systemBackground))
                            .padding([.leading, .trailing])
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .onAppear {
                    self.dictionariesAPI.getDictionaryList().then(on: DispatchQueue.main) { (paginatedResponse: PaginatedResponse<ExerciseDictionary>) in
                        let dictionaries = paginatedResponse.results
                        
                        self.allDictionaries = dictionaries
                        self.allDictionariesByID = Dictionary(uniqueKeysWithValues: dictionaries.map { ($0.id!, $0) })
                    }
                }
            }
            
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
                    
                    ExerciseSelectionView(
                        dictionary: self.exerciseSelectionPreview!,
                        exercises: self.$exercises
                    ) {
                        if let handleSelect = self.onSelectExerciseDictionary {
                            handleSelect(self.exerciseSelectionPreview!)
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

struct ExerciseListItem: View {
    let dictionary: ExerciseDictionary
    let isSelected: Bool
    
    @State private var target: [MuscleActivation] = []
    @State private var synergists: [MuscleActivation] = []
    @State private var dynamic: [MuscleActivation] = []
    
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
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(mainTitle).font(.callout).foregroundColor(isSelected ? appColor : Color.primary).fontWeight(isSelected ? .semibold : .regular)
                
                if subTitle != nil {
                    Text(subTitle!).font(.caption).foregroundColor(Color.secondary)
                }
            }
            
            Spacer()
            
            FocusedAnteriorView(
                activatedTargetMuscles: self.target,
                activatedSynergistMuscles: self.synergists,
                activatedDynamicArticulationMuscles: self.dynamic
            )
                .padding()
                .frame(width: 80, height: 90)
                .clipShape(Circle())
                .overlay(Circle().stroke(appColor, lineWidth: 1))
        }
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

struct ExerciseDictionaryListView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseDictionaryListView()
    }
}
