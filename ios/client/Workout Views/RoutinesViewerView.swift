//
//  RoutinesViewerView.swift
//  client
//
//  Created by Nadir Muzaffar on 6/25/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI
import ASCollectionView

struct ExerciseSelectionView: View {
    let dictionary: ExerciseDictionary
    
    @State private var target: [MuscleActivation] = []
    @State private var synergists: [MuscleActivation] = []
    @State private var dynamic: [MuscleActivation] = []
    
    var body: some View {
        VStack {
            Text(dictionary.name).font(.title)
            
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

struct ExerciseListItem: View {
    let dictionary: ExerciseDictionary
    
    @State private var target: [MuscleActivation] = []
    @State private var synergists: [MuscleActivation] = []
    @State private var dynamic: [MuscleActivation] = []
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(dictionary.name).font(.callout)
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

struct RoutinesViewerView: View {
    @EnvironmentObject var workoutAPI: WorkoutAPI
    @EnvironmentObject var dictionariesAPI: ExerciseDictionaryAPI
    
    @Binding var disableCloseButton: Bool
    
    @State private var allDictionaries: [ExerciseDictionary] = []
    @State private var allDictionariesByID: [Int:ExerciseDictionary] = [Int:ExerciseDictionary]()
    @State private var displayDictionaries: [ExerciseDictionary] = []
    @State private var filteredDictionaryIDs: [Int] = []
    
    @State private var workouts: [Workout] = []
    @State private var createRoutine = true
    @State private var searchTerms = ""
    
    @State private var scrollBufferSize = 50
    
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
    
    var filteredDictionaries: [ExerciseDictionary] {
        if filteredDictionaryIDs.isEmpty {
            return allDictionaries
        }
        
        return self.filteredDictionaryIDs.map { allDictionariesByID[$0]! }
    }
    
    var body: some View {
        UITableView.appearance().separatorColor = .systemGray
        UITableView.appearance().backgroundColor = feedColor.uiColor()
        UITableView.appearance().showsVerticalScrollIndicator = false

        return VStack {
            if createRoutine {
                SearchBar(text: userSearchTerm)
            
                ASTableView(data: self.filteredDictionaries, dataID: \.id) { item, _ in
                    ExerciseListItem(dictionary: item)
                        .padding([.leading, .trailing])
                }
                .onAppear {
                    self.dictionariesAPI.getDictionaryList().then(on: DispatchQueue.main) { (paginatedResponse: PaginatedResponse<ExerciseDictionary>) in
                        let dictionaries = paginatedResponse.results
                        
                        self.allDictionaries = dictionaries
                        self.allDictionariesByID = Dictionary(uniqueKeysWithValues: dictionaries.map { ($0.id!, $0) })
                    }
                }
                .edgesIgnoringSafeArea(.all)
            } else {
                VStack {
                    HStack(alignment: .top) {
                        Button(action: {
                            self.createRoutine = true
                        }) {
                            Text("Add").padding(.leading)
                        }
                        Spacer()
                        Text("")
                        Spacer()
                    }
                    .padding([.top, .bottom])
                    
                    List {
                        ForEach(self.workouts, id: \.id) { workout in
                            WorkoutTemplateView(workout: workout)
                                .background(Color.white)
                                .buttonStyle(PlainButtonStyle())
                                .padding(.top)
                        }
                        .listRowInsets(EdgeInsets())
                        .animation(.none)
                        .background(feedColor)
                    }
                    .animation(.none)
                    .onAppear {
                        _ = self.workoutAPI.getUserWorkouts(page: 0, pageSize: 20) { (response) in
                            self.workouts.append(contentsOf: response.results)
                        }
                    }
                    .border(Color.red)
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)
                .onTapGesture {
                    self.isEditing = true
            }
            
            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.text = ""
                    
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
    }
}

struct RoutinesViewerView_Previews: PreviewProvider {
    static var previews: some View {
        let binding = Binding<Bool>(
            get: { false },
            set: { _ in }
        )
        
        return RoutinesViewerView(disableCloseButton: binding)
    }
}
