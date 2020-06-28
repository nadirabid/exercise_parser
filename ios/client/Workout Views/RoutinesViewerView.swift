//
//  RoutinesViewerView.swift
//  client
//
//  Created by Nadir Muzaffar on 6/25/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct RoutinesViewerView: View {
    @EnvironmentObject var workoutAPI: WorkoutAPI
    @EnvironmentObject var dictionariesAPI: ExerciseDictionaryAPI
    
    @Binding var disableCloseButton: Bool
    
    @State private var dictionaries: [ExerciseDictionary] = []
    @State private var test: [ExerciseDictionary] = []
    @State private var filteredDictionaryIDs: [Int] = []
    @State private var workouts: [Workout] = []
    @State private var createRoutine = true
    @State private var searchTerms = ""
    
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
                        if self.searchTerms == v {
                            self.filteredDictionaryIDs = result.results
                            self.test = self.filteredDictionaries
                        }
                    }
            }
        )
    }
    
    var filteredDictionaries: [ExerciseDictionary] {
        if filteredDictionaryIDs.isEmpty {
            return dictionaries.dropLast(1400)
        }
        
        print("here")
        
        return dictionaries.filter { self.filteredDictionaryIDs.contains($0.id!) }
    }
    
    var body: some View {
        UITableView.appearance().separatorColor = .clear
        UITableView.appearance().backgroundColor = feedColor.uiColor()
        
        return VStack {
            if createRoutine {
                SearchBar(text: userSearchTerm)
                    .onAppear {
                        self.dictionariesAPI.getDictionaryList().then(on: DispatchQueue.main) { (paginatedResponse: PaginatedResponse<ExerciseDictionary>) in
                            self.dictionaries = paginatedResponse.results
                            self.test = paginatedResponse.results
                            print(paginatedResponse.results.count)
                        }
                    }
                
                List(self.test) { (dictionary: ExerciseDictionary) in
                    HStack {
                        AnteriorView(
                            activatedTargetMuscles: [],
                            activatedSynergistMuscles: [],
                            activatedDynamicArticulationMuscles: []
                        )
                            .frame(width: 40, height: 60)
                        
                        Text(dictionary.name)
                        
                        Spacer()
                    }
                }
                .animation(.none)
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
 
            TextField("Search for exercise", text: $text)
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
