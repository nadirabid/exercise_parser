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
                            WorkoutTemplateView(template: item)
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
                    
                    self.workoutTemplateAPI.getAllForMe().then { (response) in
                        self.templates = response.results
                    }
                }
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
