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
    @State private var workoutName: String = ""
    @State private var workoutNameTextField: UITextField? = nil
    @State private var isPaused = false
    @State private var editingExerciseCID: UUID? = nil
    
    private var stopwatch = Stopwatch()
    
    func handleSelect(exerciseTemplates: [ExerciseTemplate]) {
        self.exerciseTemplates.append(contentsOf: exerciseTemplates)
        self.selectExerciseDictionary = false
    }
    
    func handleSave() {
        // do a little data integrity check - sets must be greater than 0
        let exerciseTemplatesToSave = self.exerciseTemplates.filter { (exerciseTemplate) -> Bool in
            var indicesToRemove: [Int] = []
            for i in 0..<exerciseTemplate.data.sets {
                if !exerciseTemplate.data.completedSets[i] || exerciseTemplate.data.reps[i] == 0 {
                    indicesToRemove.append(i)
                }
            }
            
            for j in indicesToRemove.reversed() { // do it backwards so we dont fuck up the eelements we intend to remove
                exerciseTemplate.data.removeSetAt(index: j)
            }
            
            return exerciseTemplate.data.sets > 0
        }
        
        if exerciseTemplatesToSave.isEmpty {
            self.routerState.replaceCurrent(with: .editor(.template(.list)))
        }
        
        let workoutFromTemplate: WorkoutTemplate = WorkoutTemplate(
            id: nil,
            createdAt: nil,
            updatedAt: nil,
            name: self.workoutName,
            exercises: exerciseTemplatesToSave,
            userID: self.workoutTemplate!.userID,
            isNotTemplate: true, // this flag means its really a workout
            secondsElapsed: self.stopwatch.counter
        )
        
        print("here:presave")
        self.workoutTemplateAPI.create(workoutTemplate: workoutFromTemplate).then { _ in
            print("here:postsave")
            self.routerState.replaceCurrent(with: .userFeed)
        }
    }
    
    func handleDelete(exerciseTemplate: ExerciseTemplate) {
        self.exerciseTemplates = self.exerciseTemplates.filter({ $0.cid != exerciseTemplate.cid })
    }
    
    func handleFinish() {
        self.isPaused = true
        stopwatch.stop()
    }
    
    func handleResume() {
        self.isPaused = false
        stopwatch.start()
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
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                if !self.isPaused {
                    HStack(alignment: .center) {
                        Button(action: {
                            self.selectExerciseDictionary = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(appColor)
                                
                                Text("Exercise")
                            }
                        }
                        
                        Spacer()
                    }
                    .padding([.leading, .trailing, .bottom])
                } else {
                    HStack {
                        Button(action: {
                            self.routerState.replaceCurrent(with: .editor(.template(.list)))
                        }) {
                            Text("Discard")
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            self.handleResume()
                        }) {
                            Text("Resume")
                        }
                    }
                    .padding([.leading, .trailing, .bottom])
                }
                
                Divider()
            }
            .background(Color.white)
            
            TimerHeader(stopwatch: self.stopwatch)
            
            if isPaused {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Workout Name")
                        .font(.caption)
                        .padding([.leading, .top])
                        .padding(.bottom, 3)
                        .foregroundColor(Color.gray)
                    
                    TextField("Enter name", text: self.$workoutName, onCommit: {
                        self.workoutName = self.workoutName.trimmingCharacters(in: .whitespaces)
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
                if self.exerciseTemplates.isEmpty {
                    VStack {
                        Spacer()
                        Text("No exercises").foregroundColor(Color.secondary)
                        Spacer()
                    }
                } else {
                    GeometryReader { geometry in
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 0) {
                                ForEach(self.exerciseTemplates, id: \.cid) { item in
                                    VStack(spacing: 0) {
                                        ExerciseCreateFromTemplate(
                                            exerciseTemplate: item,
                                            showCompletionMark: true,
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
                                            showEditingOption: !self.isPaused
                                        )
                                        .disabled(self.isPaused)
                                        
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
                    .background(feedColor)
                }
                
                VStack(spacing: 0) {
                    Divider()
                    
                    GeometryReader { geometry in
                        if !self.isPaused {
                            HStack {
                                Button(action: {
                                    self.handleFinish()
                                }) {
                                    Text("Finish")
                                }
                                .frame(width: geometry.size.width)
                            }
                        } else {
                            HStack {
                                Button(action: {
                                    self.handleSave()
                                }) {
                                    Text("Save")
                                        .font(.headline)
                                }
                                .frame(width: geometry.size.width)
                            }
                        }
                    }
                    .padding(.all, 13)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .onAppear {
            if let workoutTemplate = self.workoutTemplate {
                self.workoutName = workoutTemplate.name
                self.exerciseTemplates = workoutTemplate.exercises
            }
            
            self.stopwatch.start()
        }
        .sheet(isPresented: self.$selectExerciseDictionary) {
            ExerciseDictionaryListView(onSelectExerciseTemplates: self.handleSelect) {
                self.selectExerciseDictionary = false
            }
            .environmentObject(self.exerciseDictionaryAPI)   
        }
    }
}

struct TimerHeader: View {
    @ObservedObject var stopwatch: Stopwatch
    
    var body: some View {
        HStack {
            Spacer()
            
            Text(stopwatch.convertCountToTimeString())
            
            Spacer()
        }
        .padding(10)
        .background(Color.accentColor)
        .foregroundColor(Color.white)
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
