//
//  WorkoutTemplateEditorView.swift
//  client
//
//  Created by Nadir Muzaffar on 7/16/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI
import ASCollectionView

struct WorkoutTemplateEditorView: View {
    @EnvironmentObject var routerState: RouteState
    @EnvironmentObject var exerciseDictionaryAPI: ExerciseDictionaryAPI
    @EnvironmentObject var workoutTemplateAPI: WorkoutTemplateAPI
    
    @State private var exerciseTemplates: [ExerciseTemplate] = []
    @State private var selectExerciseDictionary: Bool = false
    @State private var workoutTemplateName: String = ""
    @State private var workoutNameTextField: UITextField? = nil
    @State private var scrollView: UIScrollView? = nil
    @State private var newlyAddedExerciseTemplates: [ExerciseTemplate] = []
    @State private var editingExerciseCID: UUID? = nil
    @State private var isEditingWorkout: Bool = false
    
    func handleSelect(exerciseTemplates: [ExerciseTemplate]) {
        self.exerciseTemplates.append(contentsOf: exerciseTemplates)
        self.selectExerciseDictionary = false
        
        self.newlyAddedExerciseTemplates = exerciseTemplates
    }
    
    func handleClose() {
        selectExerciseDictionary = false
    }
    
    func handleSave() {
        // do a little data integrity check - sets must be greater than 0
        let exerciseTemplatesToSave = self.exerciseTemplates.filter { (exerciseTemplate) -> Bool in
            var indicesToRemove: [Int] = []
            for i in 0..<exerciseTemplate.data.sets {
                if exerciseTemplate.data.reps[i] == 0 {
                    indicesToRemove.append(i)
                }
            }
            
            for j in indicesToRemove.reversed() { // do it backwards so we dont fuck up the eelements we intend to remove
                exerciseTemplate.data.removeSetAt(index: j)
            }
            
            return exerciseTemplate.data.sets > 0
        }
        
        var template: WorkoutTemplate
        
        if self.workoutTemplate != nil {
            template = WorkoutTemplate(
                id: self.workoutTemplate!.id,
                createdAt: nil,
                updatedAt: nil,
                name: self.workoutTemplateName,
                exercises: exerciseTemplatesToSave,
                userID: self.workoutTemplate!.userID
            )
        } else {
            template = WorkoutTemplate(
                id: nil,
                createdAt: nil,
                updatedAt: nil,
                name: self.workoutTemplateName,
                exercises: exerciseTemplatesToSave,
                userID: nil
            )
        }
        
        if template.id == nil {
            self.workoutTemplateAPI.create(workoutTemplate: template).then { _ in
                self.routerState.replaceCurrent(with: .editor(.template(.list)))
            }
        } else {
            self.workoutTemplateAPI.put(workoutTemplate: template).then { _ in
                self.routerState.replaceCurrent(with: .editor(.template(.list)))
            }
        }
    }
    
    func handleDelete(exerciseTemplate: ExerciseTemplate) {
        self.exerciseTemplates = self.exerciseTemplates.filter({ $0.cid != exerciseTemplate.cid })
    }
    
    func handleDeleteWorkoutTemplate() {
        if let workoutTemplate = self.workoutTemplate {
            workoutTemplateAPI.delete(workoutTemplate: workoutTemplate)
                .then {
                    self.routerState.pop()
                }
                .catch { _ in
                    print("Failed to delete: ", workoutTemplate)
                }
        }
    }
    
    func isLast(exerciseTemplate: ExerciseTemplate) -> Bool {
        self.exerciseTemplates.last?.cid == exerciseTemplate.cid
    }
    
    var workoutTemplate: WorkoutTemplate? {
        if self.routerState.peek() == .editor(.template(.create)) {
            return nil
        }
        
        guard case .editor(.template(.edit(let template))) = self.routerState.peek() else {
            return nil
        }
        
        return template
    }
    
    var inEditMode: Bool {
        return self.workoutTemplate == nil || self.isEditingWorkout
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    if self.inEditMode {
                        Button(action: {
                            self.selectExerciseDictionary = true
                        }) {
                            Text("Add")
                                .foregroundColor(appColor)
                        }
                    } else {
                        Button(action: {
                            self.routerState.pop()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(Font.system(size: 18))
                                .foregroundColor(appColor)
                            
                            Text("Back")
                                .foregroundColor(appColor)
                        }
                    }
                    
                    Spacer()
                    
                    if self.workoutTemplate == nil {
                        Button(action: {
                            self.routerState.replaceCurrent(with: .editor(.template(.list)))
                        }) {
                            Text("Cancel").foregroundColor(appColor)
                        }
                    } else {
                        Button(action: {
                            self.isEditingWorkout.toggle()
                        }) {
                            if self.isEditingWorkout {
                                Text("Cancel").foregroundColor(appColor)
                            } else {
                                Text("Edit").foregroundColor(appColor)
                            }
                        }
                    }
                }
                .padding([.leading, .trailing, .bottom])
                
                Divider()
            }
            
            if self.exerciseTemplates.isEmpty {
                VStack {
                    if self.inEditMode {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Workout template name")
                                .font(.caption)
                                .padding([.leading, .top])
                                .padding(.bottom, 3)
                                .foregroundColor(Color.gray)
                            
                            TextField("Enter name", text: self.$workoutTemplateName, onCommit: {
                                self.workoutTemplateName = self.workoutTemplateName.trimmingCharacters(in: .whitespaces)
                            })
                                .padding([.leading, .trailing])
                                .padding([.top, .bottom], 12)
                                .background(Color(#colorLiteral(red: 0.9813412119, green: 0.9813412119, blue: 0.9813412119, alpha: 1)))
                                .border(Color(#colorLiteral(red: 0.9160850254, green: 0.9160850254, blue: 0.9160850254, alpha: 1)))
                        }
                    }
                    
                    Spacer()
                    Text("No exercises").foregroundColor(Color.secondary)
                    Spacer()
                }
            } else {
                GeometryReader { geometry in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) { // added this to remove spacing between items from ScrollView
                            if self.inEditMode {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("Workout template name")
                                        .font(.caption)
                                        .padding([.leading, .top])
                                        .padding(.bottom, 3)
                                        .foregroundColor(Color.gray)
                                    
                                    TextField("Enter name", text: self.$workoutTemplateName, onCommit: {
                                        self.workoutTemplateName = self.workoutTemplateName.trimmingCharacters(in: .whitespaces)
                                    })
                                        .padding([.leading, .trailing])
                                        .padding([.top, .bottom], 12)
                                        .background(Color(#colorLiteral(red: 0.9813412119, green: 0.9813412119, blue: 0.9813412119, alpha: 1)))
                                        .border(Color(#colorLiteral(red: 0.9160850254, green: 0.9160850254, blue: 0.9160850254, alpha: 1)))
                                }
                            } else {
                                HStack {
                                    Text(self.workoutTemplateName.isEmpty ? "Unnamed" : self.workoutTemplateName)
                                        .font(.title)
                                    
                                    Spacer()
                                }
                                .padding([.leading, .top])
                            }
                            
                            ForEach(self.exerciseTemplates, id: \.cid) { item in
                                VStack(spacing: 0) {
                                    ExerciseCreateFromTemplate(
                                        exerciseTemplate: item,
                                        showCompletionMark: false,
                                        viewWidth: geometry.size.width,
                                        onDelete: { self.handleDelete(exerciseTemplate: item) },
                                        onEdit: {
                                            if self.editingExerciseCID == item.cid {
                                                self.editingExerciseCID = nil
                                            } else {
                                                self.editingExerciseCID = item.cid
                                            }
                                    },
                                        isEditing: self.editingExerciseCID == item.cid,
                                        showEditingOption: self.inEditMode
                                    )
                                    
                                    Divider()
                                }
                                .background(Color.white)
                                .buttonStyle(PlainButtonStyle())
                                .animation(.none)
                            }
                            .listRowInsets(EdgeInsets())
                            .background(feedColor)
                        }
                    }
                }
            }
            
            Spacer()
            
            VStack(spacing: 0) {
                Divider()
                
                GeometryReader { geometry in
                    if self.workoutTemplate == nil {
                        HStack(spacing: 0) {
                            Button(action: {
                                self.handleSave()
                            }) {
                                Text("Save")
                                    .foregroundColor(appColor)
                            }
                            .frame(width: geometry.size.width)
                        }
                    } else if self.isEditingWorkout {
                        HStack(spacing: 0) {
                            Button(action: {
                                self.handleDeleteWorkoutTemplate()
                            }) {
                                Text("Delete")
                                    .foregroundColor(.red)
                            }
                            .frame(width: geometry.size.width / 2)
                            
                            Divider()
                            
                            Button(action: {
                                self.handleSave()
                            }) {
                                Text("Save")
                                    .foregroundColor(appColor)
                            }
                            .frame(width: geometry.size.width / 2)
                        }
                    } else if self.workoutTemplate != nil {
                        HStack(spacing: 0) {
                            Button(action: {
                                self.routerState.replaceCurrent(with: .editor(.template(.start(self.workoutTemplate!))))
                            }) {
                                Text("Start")
                                    .foregroundColor(appColor)
                            }
                            .frame(width: geometry.size.width)
                        }
                    }
                }
                .padding(.all, 13)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .onAppear {
            if let workoutTemplate = self.workoutTemplate {
                self.workoutTemplateName = workoutTemplate.name
                self.exerciseTemplates = workoutTemplate.exercises
            }
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
