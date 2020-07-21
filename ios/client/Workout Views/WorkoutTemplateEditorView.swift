//
//  WorkoutTemplateEditorView.swift
//  client
//
//  Created by Nadir Muzaffar on 7/16/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct WorkoutTemplateEditorView: View {
    @EnvironmentObject var routerState: RouteState
    @EnvironmentObject var exerciseDictionaryAPI: ExerciseDictionaryAPI
    @EnvironmentObject var workoutTemplateAPI: WorkoutTemplateAPI
    
    @State private var exerciseTemplates: [ExerciseTemplate] = []
    @State private var selectExerciseDictionary: Bool = false
    
    func handleSelect(exerciseTemplates: [ExerciseTemplate]) {
        self.exerciseTemplates.append(contentsOf: exerciseTemplates)
        self.selectExerciseDictionary = false
    }
    
    func handleClose() {
        selectExerciseDictionary = false
    }
    
    func handleSave() {
        let template = WorkoutTemplate(id: nil, createdAt: nil, updatedAt: nil, name: "Workout name", exercises: self.exerciseTemplates, userID: nil)
        self.workoutTemplateAPI.create(workoutTemplate: template).then { _ in
            self.routerState.replaceCurrent(with: .editor(.template(.list)))
        }
    }
    
    func handleDelete(exerciseTemplate: ExerciseTemplate) {
        self.exerciseTemplates = self.exerciseTemplates.filter({ $0.cid != exerciseTemplate.cid })
    }
    
    var body: some View {
        UITableView.appearance().separatorColor = .clear
        UITableView.appearance().backgroundColor = UIColor.systemBackground
        UITableView.appearance().showsVerticalScrollIndicator = false
        
        return VStack(spacing: 0) {
            VStack {
                HStack {
                    Button(action: {
                        self.routerState.replaceCurrent(with: .editor(.template(.list)))
                    }) {
                        Text("Cancel")
                    }
                    .frame(width: 100, alignment: .leading)
                    
                    Spacer()
                    
                    Button(action: { self.handleSave() }) {
                        Text("Save")
                    }
                    .frame(width: 100, alignment: .trailing)
                    .disabled(self.exerciseTemplates.isEmpty)
                }
                .padding([.leading, .trailing])
                
                Divider()
            }
            
            
            if self.exerciseTemplates.isEmpty {
                VStack {
                    Spacer()
                    Text("No exercises").foregroundColor(Color.secondary)
                    Spacer()
                }
                .onAppear {
                    self.exerciseDictionaryAPI.getDictionaryList().then(on: DispatchQueue.main) { (paginatedResponse: PaginatedResponse<ExerciseDictionary>) in
                        let dictionaries = paginatedResponse.results
                        
                        self.exerciseTemplates = dictionaries.suffix(1000).prefix(7).map { d in
                            ExerciseTemplate(
                                data: ExerciseTemplateData(
                                    isSetsFieldEnabled: true,
                                    isRepsFieldEnabled: true,
                                    isWeightFieldEnabled: true,
                                    isTimeFieldEnabled: false,
                                    isDistanceFieldEnabled: false
                                ),
                                exerciseDictionaries: [d]
                            )
                        }
                    }
                }
            } else {
                GeometryReader { geometry in
                    ScrollView(showsIndicators: false) {
                        ForEach(self.exerciseTemplates, id: \.cid) { item in
                            VStack {
                                ExerciseTemplateEditorView(
                                    exerciseTemplate: item,
                                    viewWidth: geometry.size.width,
                                    onDelete: { self.handleDelete(exerciseTemplate: item) }
                                )
                                .padding()
                                
                                Divider()
                            }
                            .listRowInsets(EdgeInsets())
                        }
                    }
                }
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: { self.selectExerciseDictionary = true }) {
                    Text("Add exercise")
                        .foregroundColor(appColor)
                    
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(appColor)
                }
            }
            .padding([.leading, .trailing])
        }
        .sheet(isPresented: self.$selectExerciseDictionary) {
            VStack {
                ExerciseDictionaryListView(onSelectExerciseTemplates: self.handleSelect) {
                    self.selectExerciseDictionary = false
                }
                .environmentObject(self.exerciseDictionaryAPI)
            }
            .padding(.top)
            .animation(.default)
        }
    }
}

struct WorkoutTemplateEditorView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutTemplateEditorView()
    }
}
