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
    @EnvironmentObject var routerState: RouteState
    @EnvironmentObject var workoutAPI: WorkoutAPI
    @EnvironmentObject var workoutTemplateAPI: WorkoutTemplateAPI
    @EnvironmentObject var dictionariesAPI: ExerciseDictionaryAPI

    @Binding var disableCloseButton: Bool
    
    @State private var templates: [WorkoutTemplate] = []
    @State private var createRoutine = false
    
    func delete(workoutTemplate: WorkoutTemplate) {
        self.templates = self.templates.filter { $0.id != workoutTemplate.id }
        
        workoutTemplateAPI.delete(workoutTemplate: workoutTemplate).catch { _ in
            print("Failed to delete: ", workoutTemplate)
        }
    }
    
    var isShowingList: Bool {
        self.routerState.peek() == .editor(.template(.list))
    }
    
    var body: some View {
        return VStack {
            if self.routerState.peek() == .editor(.template(.create)) {
                WorkoutTemplateEditorView()
            } else {
                VStack {
                    HStack {
                        Button(action: {
                            self.routerState.replaceCurrent(with: .editor(.template(.create)))
                        }) {
                            Text("Add")
                        }
                        
                        Spacer()
                    }
                    .padding(.leading)
                    
                    List {
                        ForEach(self.templates, id: \.id) { item in
                            WorkoutTemplateView(
                                template: item,
                                onDelete: { self.delete(workoutTemplate: item) }
                            )
                                .background(Color.white)
                                .buttonStyle(PlainButtonStyle())
                                .padding(.top)
                        }
                        .listRowInsets(EdgeInsets())
                        .animation(.none)
                        .background(feedColor)
                    }
                    .animation(.none)
                }
                .edgesIgnoringSafeArea(.bottom)
                .onAppear {
                    UITableView.appearance().separatorColor = .clear
                    UITableView.appearance().backgroundColor = feedColor.uiColor()
                    UITableView.appearance().showsVerticalScrollIndicator = false
                    
                    self.workoutTemplateAPI.all().then { (response) in
                        self.templates = response.results
                    }
                }
            }
        }
    }
}
