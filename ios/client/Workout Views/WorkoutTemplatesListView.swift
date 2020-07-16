//
//  RoutinesViewerView.swift
//  client
//
//  Created by Nadir Muzaffar on 6/25/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI
import ASCollectionView

struct WorkoutTemplatesListView: View {
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
                WorkoutTemplateEditorView()
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
        
        return WorkoutTemplatesListView(disableCloseButton: binding)
    }
}
