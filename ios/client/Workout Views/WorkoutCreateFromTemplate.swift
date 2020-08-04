//
//  WorkoutFromTemplate.swift
//  client
//
//  Created by Nadir Muzaffar on 7/29/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI
import ASCollectionView

struct WorkoutCreateFromTemplate: View {
    @EnvironmentObject var routerState: RouteState
    @EnvironmentObject var exerciseDictionaryAPI: ExerciseDictionaryAPI
    @EnvironmentObject var workoutTemplateAPI: WorkoutTemplateAPI
    
    @State private var exerciseTemplates: [ExerciseTemplate] = []
    @State private var selectExerciseDictionary: Bool = false
    @State private var workoutTemplateName: String = ""
    @State private var workoutNameTextField: UITextField? = nil
    @State private var scrollView: UIScrollView? = nil
    @State private var newlyAddedExerciseTemplates: [ExerciseTemplate] = []
    @State private var isPaused = false
    
    private var stopwatch = Stopwatch()
    
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

    func isLast(exerciseTemplate: ExerciseTemplate) -> Bool {
        self.exerciseTemplates.last?.cid == exerciseTemplate.cid
    }
    
    var workoutTemplate: WorkoutTemplate? {
        if !RouteEditorTemplate.isStartTemplate(route: self.routerState.peek()) {
            return nil
        }
        
        guard case .editor(.template(.start(let template))) = self.routerState.peek() else {
            return nil
        }
        
        return template
    }
    
    var body: some View {
        UITableView.appearance().separatorColor = .clear
        UITableView.appearance().backgroundColor = feedColor.uiColor()
        UITableView.appearance().showsVerticalScrollIndicator = false
        
        return VStack(spacing: 0) {
            if isPaused {
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
                }
            }
            
            if self.workoutTemplate == nil {
                EmptyView() // I guess there's lag in rendering - router can change and subview gets update before the parent view
            } else {
                WorkoutCreateFromTemplateMetaMetricsView(workoutTemplate: workoutTemplate!, stopwatch: self.stopwatch)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
            
                if self.exerciseTemplates.isEmpty {
                    VStack {
                        Spacer()
                        Text("No exercises").foregroundColor(Color.secondary)
                        Spacer()
                    }
                } else {
                    GeometryReader { geometry in
                        List {
                            ForEach(self.exerciseTemplates, id: \.cid) { item in
                                VStack(spacing: 0) {
                                    ExerciseCreateFromTemplate(
                                        exerciseTemplate: item,
                                        viewWidth: geometry.size.width,
                                        onDelete: { self.handleDelete(exerciseTemplate: item) }
                                    )
                                        .padding()
                                    
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
                
                VStack(spacing: 0) {
                    Divider()
                    
                    GeometryReader { geometry in
                        HStack {
                            Button(action: {
                                self.routerState.replaceCurrent(with: .editor(.template(.list)))
                            }) {
                                HStack {
                                    Image(systemName:"stop.circle")
                                        .font(.system(size: 15, weight: .medium, design: .default))
                                        .foregroundColor(Color.secondary)
                                    
                                    Text("Stop")
                                        .foregroundColor(Color.secondary)
                                        .animation(.none)
                                }
                                .padding(.leading)
                            }
                            .frame(width: geometry.size.width / 2)
                            
                            Divider()
                            
                            Button(action: {
                                self.selectExerciseDictionary = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle")
                                        .font(.system(size: 15, weight: .medium, design: .default))
                                        .foregroundColor(Color.secondary)
                                    
                                    Text("Add")
                                        .foregroundColor(Color.secondary)
                                        .animation(.none)
                                }
                                .padding(.trailing)
                            }
                            .frame(width: geometry.size.width / 2)
                        }
                    }
                    .padding(.all, 13)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .onAppear {
            if let workoutTemplate = self.workoutTemplate {
                self.workoutTemplateName = workoutTemplate.name
                self.exerciseTemplates = workoutTemplate.exercises
            }
            
            self.stopwatch.start()
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

struct WorkoutCreateFromTemplateMetaMetricsView: View {
    @State var workoutTemplate: WorkoutTemplate
    @ObservedObject var stopwatch: Stopwatch
    
    var totalWeight: Int {
        return 0
    }
    
    var totalDistance: Float {
        return 0
    }
    
    var totalSets: Int {
        return 0
    }
    
    var totalReps: Int {
        return 0
    }
    
    var body: some View {
        HStack(spacing: 10) {
            WorkoutDetail(
                name: "Time",
                value: secondsToElapsedTimeString(self.stopwatch.counter)
            )
                .fixedSize()
            
            DividerSpacer()
            
            WorkoutDetail(
                name: "Sets",
                value: "\(self.totalSets)"
            )
            
            DividerSpacer()
            
            WorkoutDetail(
                name: "Reps",
                value: "\(self.totalReps)"
            )
            
            DividerSpacer()
            
            WorkoutDetail(
                name: "Distance",
                value: "\(self.totalDistance) mi"
            )
        }
    }
}

struct WorkoutFromTemplate_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutCreateFromTemplate()
    }
}
