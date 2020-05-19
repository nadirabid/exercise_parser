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
    
    init() {
        UITableView.appearance().separatorColor = .clear
    }
    
    var isUserButtonPressed: Bool {
        return self.route.current == .userFeed || self.route.current == .userMetrics
    }
    
    var isSubscriptionButtonPressed: Bool {
        return self.route.current == .subscriptionFeed
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
                } else if route.current == .editor {
                    EditableWorkoutView()
                } else {
                    VStack(spacing: 0) {
                        if route.current == .userFeed || route.current == .userMetrics {
                            UserFeedView()
                        } else if route.current == .subscriptionFeed {
                            VStack(alignment: .center) {
                                ZStack {
                                    HStack {
                                        Spacer()
                                        
                                        Text("RYDEN")
                                            .foregroundColor(appColor)
                                            .fontWeight(.heavy)
                                            .font(.subheadline)
                                        
                                        Spacer()
                                    }
                                    
                                    HStack {
                                        Spacer()
                                        
                                        Button(action: { self.route.showHelp = true }) {
                                            Image(systemName: "questionmark.circle")
                                                .padding(.trailing)
                                                .foregroundColor(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                                                .font(.body)
                                        }
                                    }
                                }
                                
                                Divider()
                            }
                            
                            SubscriptionFeedView()
                        }
                        
                        VStack {
                            Divider()
                            HStack {
                                Spacer()
                                Spacer()
                                
                                Button(action: {
                                    if !self.isUserButtonPressed {
                                        self.route.current = .userFeed
                                    }
                                }) {
                                    HomeIconShape()
                                        .fill(self.isUserButtonPressed ? secondaryAppColor : Color.gray)
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
                                
                                Button(action: {
                                    if !self.isSubscriptionButtonPressed {
                                        self.route.current = .subscriptionFeed
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
            
            if route.editUserProfile {
                EditorUserProfileView()
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
