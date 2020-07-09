//
//  RoutinesViewerView.swift
//  client
//
//  Created by Nadir Muzaffar on 6/25/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI
import ASCollectionView

struct ExerciseTemplateView: View {
    var exerciseTemplate: ExerciseTemplate
    
    var labelFont: Font {
        .system(size: 9)
    }
    
    var title: String {
        let tokens = exerciseTemplate.exerciseDictionaries.first!.name.split(separator: "(")
        
        return tokens.first!.description
    }
    
    var subTitle: String? {
        let tokens = exerciseTemplate.exerciseDictionaries.first!.name.split(separator: "(")
        
        if tokens.count > 1 {
            var s = tokens.last!.description
            s.removeLast()
            return s
        }
        
        return nil
    }
    
    var body: some View {
        return VStack(alignment: .leading) {
            HStack(spacing: 0) {
                Text(title)
                
                if subTitle != nil {
                    Text(" - \(subTitle!)")
                        .font(.caption)
                        .foregroundColor(Color.secondary)
                }
            }
            
            HStack(spacing: 8) {
                if exerciseTemplate.data.sets {
                    HStack(spacing: 0) {
                        Text("sets / ".uppercased())
                            .font(labelFont)
                            .foregroundColor(Color.secondary)
                            .fixedSize()
                        
                        Text("5")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .fixedSize()
                    }
                }
                
                if exerciseTemplate.data.reps {
                    HStack(spacing: 0) {
                        Text("reps / ".uppercased())
                            .font(labelFont)
                            .foregroundColor(Color.secondary)
                            .fixedSize()
                        
                        Text("9")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .fixedSize()
                    }
                }
                
                if exerciseTemplate.data.weight {
                    HStack(spacing: 0) {
                        Text("lbs / ".uppercased())
                            .font(labelFont)
                            .foregroundColor(Color.secondary)
                            .fixedSize()
                        
                        Text("135")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .fixedSize()
                    }
                }
                
                if exerciseTemplate.data.distance {
                    HStack(spacing: 0) {
                        Text("mi / ".uppercased())
                            .font(labelFont)
                            .foregroundColor(Color.secondary)
                            .fixedSize()
                        
                        Text("2")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .fixedSize()
                    }
                }
                
                if exerciseTemplate.data.time {
                    HStack(spacing: 0) {
                        Text("time / ".uppercased())
                            .font(labelFont)
                            .foregroundColor(Color.secondary)
                            .fixedSize()
                        
                        Text("30s")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .fixedSize()
                    }
                }
            }
        }
    }
}

struct RoutineEditorView: View {
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
        
        return VStack {
            ScrollView {
                ForEach(self.exerciseTemplates, id: \.cid) { item in
                    HStack {
                        ExerciseTemplateView(exerciseTemplate: item)
                        Spacer()
                    }
                    .padding([.leading, .bottom])
                }
            }
            
            Spacer()
            
            HStack {
                Button(action: { self.selectExerciseDictionary = true }) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(appColor)
                    
                    Text("Add exercise")
                        .foregroundColor(appColor)
                }
                
                Spacer()
            }
            .padding(.leading)
        }
        .sheet(isPresented: self.$selectExerciseDictionary) {
            ExerciseDictionaryListView(onSelectExerciseTemplates: self.handleSelect) {
                self.selectExerciseDictionary = false
            }
            .environmentObject(self.exerciseDictionaryAPI)
            .padding(.top)
        }
    }
}

struct RoutinesViewerView: View {
    @EnvironmentObject var workoutAPI: WorkoutAPI
    @EnvironmentObject var dictionariesAPI: ExerciseDictionaryAPI
    
    @Binding var disableCloseButton: Bool
    
    @State private var workouts: [Workout] = []
    @State private var createRoutine = true
    
    var body: some View {
        UITableView.appearance().separatorColor = .clear
        UITableView.appearance().backgroundColor = feedColor.uiColor()
        UITableView.appearance().showsVerticalScrollIndicator = false

        return VStack {
            if createRoutine {
                RoutineEditorView()
            } else {
                VStack {
                    HStack {
                        Button(action: {
                            self.createRoutine = true
                        }) {
                            Text("Add")
                        }
                        
                        Spacer()
                    }
                    .padding(.leading)
                    
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
                }
                .edgesIgnoringSafeArea(.bottom)
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
