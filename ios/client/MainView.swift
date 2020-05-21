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
    
    var isUserButtonPressed: Bool {
        return self.route.peek() == .userFeed || self.route.peek() == .userMetrics
    }
    
    var isSubscriptionButtonPressed: Bool {
        return self.route.peek() == .subscriptionFeed
    }
    
    var navigationBarBottomPadding: CGFloat {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if (keyWindow?.safeAreaInsets.bottom ?? 0) > 0 {
            return 0
        }
        
        return 8
    }
    
    var body: some View {
        ZStack {
            VStack {
                if userState.authorization < 1 {
                    #if targetEnvironment(simulator)
                    SignInDevView()
                    #else
                    SignInView()
                    #endif
                } else if route.peek() == .editor {
                    CreateWorkoutView()
                } else if route.peek() == .userEdit {
                    EditorUserProfileView()
                } else {
                    VStack(spacing: 0) {
                        if route.peek() == .userFeed || route.peek() == .userMetrics {
                            UserFeedView()
                        } else if route.peek() == .subscriptionFeed {
                            SubscriptionFeedView()
                        }
                        
                        VStack {
                            Divider()
                            HStack {
                                Spacer()
                                Spacer()
                                
                                Button(action: {
                                    if !self.isUserButtonPressed {
                                        self.route.replaceCurrent(with: .userFeed)
                                    }
                                }) {
                                    HomeIconShape()
                                        .fill(self.isUserButtonPressed ? secondaryAppColor : Color.gray)
                                        .frame(height: 20)
                                }
                                
                                Spacer()
                                
                                Button(action: { self.route.replaceCurrent(with: .editor) }) {
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
                                
                                Button(action: {
                                    if !self.isSubscriptionButtonPressed {
                                        self.route.replaceCurrent(with: .subscriptionFeed)
                                    }
                                }) {
                                    StreamIconShape()
                                        .fill(self.isSubscriptionButtonPressed ? secondaryAppColor : Color.gray)
                                        .frame(height: 20)
                                }
                                
                                Spacer()
                                Spacer()
                            }
                        }
                        .padding(.bottom, navigationBarBottomPadding)
                    }
                }
            }
            
            if route.showHelp {
                Color.white.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    HStack(alignment: .top) {
                        Spacer()
                        Text("")
                        Spacer()
                        
                        Button(action: { self.route.showHelp = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color.black)
                                .font(.system(size: 24))
                                .padding([.top, .trailing], 24)
                        }
                    }
                    .padding(.bottom)
                    
                    Divider()
                    
                    ScrollView {
                        HelpView().padding([.top, .leading, .trailing])
                    }
                    
                    Spacer()
                }
                .statusBar(hidden: true)
                .edgesIgnoringSafeArea(.all)
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
