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
                #if targetEnvironment(simulator)
                SignInDevView()
                #else
                SignInView()
                #endif
            } else if route.current == .editor {
                EditableWorkoutView()
            } else {
                VStack(spacing: 0) {
                    VStack(alignment: .center) {
                        Text("RYDEN")
                            .foregroundColor(appColor)
                            .fontWeight(.heavy)
                            .font(.subheadline)
                        
                        Divider()
                    }
                        .background(Color.white)
                    
                    if route.current == .feed {
                        FeedView()
                    } else if route.current == .subscribtion_feed {
                        SubscriptionFeedView()
                    }
                    
                    VStack {
                        Divider()
                        HStack {
                            Spacer()
                            Spacer()
                            
                            Button(action: { self.route.current = .feed }) {
                                HomeIconShape()
                                    .stroke(self.route.current == .feed ? appColor : Color.gray)
                                    .frame(height: 22)
                            }
                            
                            Spacer()
                            
                            Button(action: { self.route.current = .editor }) {
                                ZStack {
                                    Circle()
                                        .stroke(appColor, lineWidth: 2)
                                        .shadow(color: Color.gray.opacity(0.3), radius: 1.0)
                                        .frame(width: 40, height: 40)
                                    
                                    Circle()
                                        .fill(appColor)
                                        .shadow(color: Color.gray.opacity(0.3), radius: 1.0)
                                        .frame(width: 20, height: 20)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: { self.route.current = .subscribtion_feed }) {
                                StreamIconShape()
                                    .stroke(self.route.current == .subscribtion_feed ? appColor : Color.gray)
                                    .frame(height: 22)
                            }
                            
                            Spacer()
                            Spacer()
                        }
                    }
                        .background(Color.white)
                }
                    .background(feedColor)
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
            .environmentObject(EditableWorkoutState())
            .environmentObject(MockWorkoutAPI(userState: userState) as WorkoutAPI)
            .environmentObject(MockExerciseAPI(userState: userState) as ExerciseAPI)
            .environmentObject(AuthAPI())
    }
}
