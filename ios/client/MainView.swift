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
                    if route.current == .userFeed || route.current == .userMetrics {
                        FeedView()
                    } else if route.current == .subscriptionFeed {
                        VStack(alignment: .center) {
                            Text("RYDEN")
                                .foregroundColor(appColor)
                                .fontWeight(.heavy)
                                .font(.subheadline)
                            
                            Divider()
                        }
                            .background(Color.white)
                        
                        SubscriptionFeedView()
                    }
                    
                    VStack {
                        Divider()
                        HStack {
                            Spacer()
                            Spacer()
                            
                            Button(action: { self.route.current = .userFeed }) {
                                HomeIconShape()
                                    .fill(self.route.current == .userFeed ? secondaryAppColor : Color.gray)
                                    .frame(height: 20)
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
                            
                            Button(action: { self.route.current = .subscriptionFeed }) {
                                StreamIconShape()
                                    .fill(self.route.current == .subscriptionFeed ? secondaryAppColor : Color.gray)
                                    .frame(height: 20)
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
