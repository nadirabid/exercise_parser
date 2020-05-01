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
  
    @State var offset: CGSize = CGSize.zero
    
    var body: some View {
        return VStack {
            AnteriorView()
                .offset(x: self.offset.width, y: self.offset.height)
                .gesture(DragGesture()
                    .onChanged({ value in
                        self.offset = value.translation
                    })
                )
            
            PosteriorView()
        }
    }
    
//    var body: some View {
//        VStack {
//            if userState.authorization < 1 {
//                #if targetEnvironment(simulator)
//                SignInDevView()
//                #else
//                SignInView()
//                #endif
//            } else {
//                if route.current == .feed {
//                    VStack(spacing: 0) {
//                        VStack(alignment: .center) {
//                            Text("RYDEN")
//                                .foregroundColor(appColor)
//                                .fontWeight(.heavy)
//                                .font(.subheadline)
//
//                            Divider()
//                        }
//                            .background(Color.white)
//
//                        FeedView()
//
//                        VStack {
//                            Divider()
//                            HStack {
//                                Spacer()
//
//                                Button(action: { self.route.current = .editor }) {
//                                    ZStack {
//                                        Circle()
//                                            .stroke(appColor, lineWidth: 2)
//                                            .shadow(color: Color.gray.opacity(0.3), radius: 1.0)
//                                            .frame(width: 50, height: 50)
//
//                                        Circle()
//                                            .fill(appColor)
//                                            .shadow(color: Color.gray.opacity(0.3), radius: 1.0)
//                                            .frame(width: 20, height: 20)
//                                    }
//                                }
//
//                                Spacer()
//                            }
//                                .padding(.top, 5)
//                        }
//                            .background(Color.white)
//                    }
//                        .background(feedColor)
//                } else if route.current == .editor {
//                    EditableWorkoutView()
//                }
//            }
//        }
//    }
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
            .environmentObject(UserAPI())
    }
}
