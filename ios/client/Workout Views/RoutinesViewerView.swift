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
    @Binding var exercises: [ExerciseTemplate]
    
    var onClose: (() -> Void)? = nil
    
    @State private var target: [MuscleActivation] = []
    @State private var synergists: [MuscleActivation] = []
    @State private var dynamic: [MuscleActivation] = []
    
    @State private var sets: Bool = false
    @State private var reps: Bool = false
    @State private var time: Bool = false
    @State private var distance: Bool = false
    @State private var weight: Bool = false
    
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
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading) {
                Text(mainTitle).font(.title)
            
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
            
                SelectFieldButtonView(selected: $sets, title: "Sets")
                SelectFieldButtonView(selected: $reps, title: "Reps")
                SelectFieldButtonView(selected: $weight, title: "Weight")
                SelectFieldButtonView(selected: $time, title: "Time")
                SelectFieldButtonView(selected: $distance, title: "Distance")
            }
            
            Spacer()
            
            GeometryReader { geometry in
                Button(action: {
                    let template = ExerciseTemplate(
                        data: ExerciseTemplateDataFields(sets: self.sets, reps: self.reps, weight: self.weight, time: self.time, distance: self.distance),
                        exerciseDictionaries: [self.dictionary]
                    )
                    
                    self.exercises.append(template)
                    
                    if let handleClose = self.onClose {
                        handleClose()
                    }
                }) {
                    Text("Select")
                        .font(.headline)
                        .foregroundColor(Color.white)
                        .padding()
                        .frame(width: geometry.size.width)
                        .background(appColor)
                        .cornerRadius(6)
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .fixedSize(horizontal: false, vertical: true)
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

struct RoutinesViewerView: View {
    @EnvironmentObject var workoutAPI: WorkoutAPI
    @EnvironmentObject var dictionariesAPI: ExerciseDictionaryAPI
    
    @Binding var disableCloseButton: Bool
    
    @State private var allDictionaries: [ExerciseDictionary] = []
    @State private var allDictionariesByID: [Int:ExerciseDictionary] = [Int:ExerciseDictionary]()
    @State private var filteredDictionaryIDs: [Int] = []
    
    @State private var workouts: [Workout] = []
    @State private var createRoutine = true
    @State private var searchTerms = ""
    
    @State private var exerciseSelectionPreview: ExerciseDictionary? = nil
    @State private var exercises: [ExerciseTemplate] = []
    
    func isSelected(exerciseDictionary: ExerciseDictionary) -> Bool {
        return self.exercises.contains(where: { $0.exerciseDictionaries.contains(where: { $0.id == exerciseDictionary.id }) })
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
                ZStack {
                    VStack {
                        SearchBarView(searchText: userSearchTerm)
                    
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
                        
                        GeometryReader { geometry in
                            Button(action: {}) {
                                Text("Done")
                                    .font(.headline)
                                    .foregroundColor(Color.white)
                                    .padding([.top, .bottom])
                                    .frame(width: geometry.size.width)
                                    .background(appColor)
                                    .cornerRadius(6)
                            }
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                    }
                    
                    if exerciseSelectionPreview != nil {
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
                                dictionary: exerciseSelectionPreview!,
                                exercises: self.$exercises
                            ) {
                                print("Here")
                                self.exerciseSelectionPreview = nil
                            }
                                .padding(.bottom)
                                .padding(.bottom)
                        }
                        .background(Color(UIColor.systemBackground))
                        .edgesIgnoringSafeArea(.bottom)
                    }
                }
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

struct RoutinesViewerView_Previews: PreviewProvider {
    static var previews: some View {
        let binding = Binding<Bool>(
            get: { false },
            set: { _ in }
        )
        
        return RoutinesViewerView(disableCloseButton: binding)
    }
}
