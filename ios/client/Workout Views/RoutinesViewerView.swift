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
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Barbell curls")
            
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
    var exerciseTemplates: [ExerciseTemplate] = []
    
    @State var selectExerciseDictionary: Bool = false
    
    func handleSelectExerciseDictionary(exerciseDictionary: ExerciseDictionary) {
        
    }
    
    func handleClose() {
        selectExerciseDictionary = false
    }
    
    var body: some View {
        VStack {
            List(exerciseTemplates) { item in
                ExerciseTemplateView(exerciseTemplate: item)
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
            ExerciseDictionaryListView(onSelectExerciseDictionary: self.handleSelectExerciseDictionary) {
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
