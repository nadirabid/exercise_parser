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
        
        let template = WorkoutTemplate(
            id: nil,
            createdAt: nil,
            updatedAt: nil,
            name: self.workoutTemplateName,
            exercises: exerciseTemplatesToSave,
            userID: nil
        )
        
        self.workoutTemplateAPI.create(workoutTemplate: template).then { _ in
            self.routerState.replaceCurrent(with: .editor(.template(.list)))
        }
    }
    
    func handleDelete(exerciseTemplate: ExerciseTemplate) {
        self.exerciseTemplates = self.exerciseTemplates.filter({ $0.cid != exerciseTemplate.cid })
    }
    
    func isLast(exerciseTemplate: ExerciseTemplate) -> Bool {
        self.exerciseTemplates.last?.cid == exerciseTemplate.cid
    }
    
    var body: some View {
        UITableView.appearance().separatorColor = .clear
        UITableView.appearance().backgroundColor = UIColor.systemBackground
        UITableView.appearance().showsVerticalScrollIndicator = false
        
        return VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Workout name")
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
                    .introspectTextField { textField in
                        if self.workoutNameTextField ==  nil { // only become first responder the first time
                            textField.becomeFirstResponder()
                        }
                        self.workoutNameTextField = textField
                    }
            }
            .padding(.bottom)
            
            if self.exerciseTemplates.isEmpty {
                VStack {
                    Spacer()
                    Text("No exercises").foregroundColor(Color.secondary)
                    Spacer()
                }
                .onAppear {
                    // TODO: remove this code
                    self.exerciseDictionaryAPI.getDictionaryList().then(on: DispatchQueue.main) { (paginatedResponse: PaginatedResponse<ExerciseDictionary>) in
                        let dictionaries = paginatedResponse.results
                        
                        self.exerciseTemplates = dictionaries.suffix(1000).prefix(3).map { d in
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
                                    .padding([.leading, .trailing])

                                if !self.isLast(exerciseTemplate: item) {
                                    Divider()
                                }
                            }
                            .listRowInsets(EdgeInsets())
                        }
                    }
                    .introspectScrollView { (scrollView: UIScrollView) in
                        if scrollView != self.scrollView {
                            self.scrollView = scrollView
                        }
                        
                        if self.newlyAddedExerciseTemplates.count > 0 {
                            if let scrollView = self.scrollView {
                                let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
                                scrollView.setContentOffset(bottomOffset, animated: true)
                            }
                            
                            self.newlyAddedExerciseTemplates = []
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
            .padding()
            
            VStack(spacing: 0) {
                Divider()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        self.handleSave()
                    }) {
                        Text("Create")
                            .foregroundColor(Color.secondary)
                            .animation(.none)
                    }
                    
                    Spacer()
                    Divider()
                    Spacer()
                    
                    Button(action: {
                        self.routerState.replaceCurrent(with: .editor(.template(.list)))
                    }) {
                        Text("Cancel")
                            .foregroundColor(Color.secondary)
                            .animation(.none)
                    }
                    
                    Spacer()
                }
                .padding(.all, 13)
                .fixedSize(horizontal: false, vertical: true)
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

struct WorkoutTemplateEditorView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutTemplateEditorView()
    }
}
