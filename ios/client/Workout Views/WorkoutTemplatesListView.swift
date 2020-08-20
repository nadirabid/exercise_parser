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
    
    @State private var templates: [WorkoutTemplate] = []
    @State private var createRoutine = false
    
    func delete(workoutTemplate: WorkoutTemplate) {
        self.templates = self.templates.filter { $0.id != workoutTemplate.id }
        
        workoutTemplateAPI.delete(workoutTemplate: workoutTemplate).catch { _ in
            print("Failed to delete: ", workoutTemplate)
        }
    }
    
    func delete(at offset: IndexSet) {
        for i in 0..<self.templates.count {
            if offset.contains(i) {
                let workoutTemplateToDelete = templates[i]
                
                workoutTemplateAPI.delete(workoutTemplate: workoutTemplateToDelete).catch { _ in
                    print("Failed to delete: ", workoutTemplateToDelete)
                }
            }
        }
        
        self.templates.remove(atOffsets: offset)
    }
    
    var isShowingList: Bool {
        self.routerState.peek() == .editor(.template(.list))
    }
    
    var body: some View {
        return VStack {
            if self.routerState.peek() == .editor(.template(.create)) {
                WorkoutTemplateEditorView()
            } else if RouteEditorTemplate.isEditTemplate(route: self.routerState.peek()) {
                WorkoutTemplateEditorView()
            } else if RouteEditorTemplate.isStartTemplate(route: self.routerState.peek()) {
                WorkoutCreateFromTemplate()
            } else {
                VStack(spacing: 0) {
                    List {
                        ForEach(self.templates, id: \.id) { item in
                            Button(action: {
                                self.routerState.push(route: .editor(.template(.edit(item))))
                            }) {
                                VStack(spacing: 0) {
                                    WorkoutTemplateView(
                                        template: item,
                                        onDelete: { self.delete(workoutTemplate: item) },
                                        onEdit: { self.routerState.replaceCurrent(with: .editor(.template(.edit(item)))) }
                                    )
                                        .padding([.top, .leading, .bottom])
                                    
                                    Divider()
                                }
                                .background(Color.white)
                            }
                        }
                        .onDelete(perform: self.delete)
                        .listRowInsets(EdgeInsets())
                        .animation(.none)
                        .background(feedColor)
                    }
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
                .onDisappear {
                    self.templates = [] // some weird bug requires me to do this or the new data in onAppear doesn't take effect
                }
            }
        }
    }
}
