//
//  WorkoutTemplateEditorView.swift
//  client
//
//  Created by Nadir Muzaffar on 7/16/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct WorkoutTemplateEditorView: View {
    @EnvironmentObject var exerciseDictionaryAPI: ExerciseDictionaryAPI
    
    @State private var exerciseTemplates: [ExerciseTemplate] = []
    @State private var selectExerciseDictionary: Bool = false
    
    func handleSelect(exerciseTemplates: [ExerciseTemplate]) {
        self.exerciseTemplates.append(contentsOf: exerciseTemplates)
        self.selectExerciseDictionary = false
    }
    
    func handleClose() {
        selectExerciseDictionary = false
    }
    
    var body: some View {
        UITableView.appearance().separatorColor = .clear
        UITableView.appearance().backgroundColor = UIColor.systemBackground
        UITableView.appearance().showsVerticalScrollIndicator = false
        
        return VStack(spacing: 0) {
            VStack {
                HStack {
                    Button(action: {}) {
                        Text("Cancel")
                    }
                    .frame(width: 100, alignment: .leading)
                    
                    Spacer()
                    
                    Button(action: {}) {
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
                                    viewWidth: geometry.size.width
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
