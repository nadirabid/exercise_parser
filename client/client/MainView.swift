//
//  MainView.swift
//  client
//
//  Created by Nadir Muzaffar on 3/9/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var route: RouteState
    @EnvironmentObject var userState: UserState
    
    var body: some View {
        VStack {
            if userState.authorization < 1 {
                SignInView()
            } else {
                if route.current == .feed {
                    FeedView()
                    
                    Button(action: { self.route.current = .editor }) {
                        ZStack {
                            Circle()
                                .stroke(appColor, lineWidth: 2)
                                .shadow(color: Color.gray.opacity(0.3), radius: 1.0)
                                .frame(width: 50, height: 50)
                            
                            Circle()
                                .fill(appColor)
                                .shadow(color: Color.gray.opacity(0.3), radius: 1.0)
                                .frame(width: 20, height: 20)
                        }
                    }
                    .padding(.top, 5)
                } else if route.current == .editor {
                    WorkoutEditorView().padding([.trailing, .leading])
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let userState = UserState()
        
        return MainView()
            .environmentObject(RouteState())
            .environmentObject(UserState())
            .environmentObject(WorkoutEditorState())
            .environmentObject(WorkoutAPI(userState: userState))
            .environmentObject(ExerciseAPI(userState: userState))
            .environmentObject(UserAPI())
    }
}
