//
//  Feed.swift
//  client
//
//  Created by Nadir Muzaffar on 3/1/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Alamofire
import SwiftUI
import Combine

struct FeedView: View {
    @EnvironmentObject var userState: UserState
    @EnvironmentObject var routeState: RouteState
    @EnvironmentObject var workoutAPI: WorkoutAPI
    @State private var feedDataPublisher: AnyCancellable? = nil
    @State private var feedData: PaginatedResponse<Workout>? = nil
    
    @State private var scrollViewContentOffset = CGFloat(0)
    @State private var height: CGFloat = 130
    
    var body: some View {
        return VStack(spacing: 0) {
            if self.feedData == nil {
                Spacer()
                HStack {
                    Spacer()
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                    Spacer()
                }
                Spacer()
            } else if self.feedData != nil && self.feedData?.results.count ?? 0 > 0  {
                HStack(alignment: .center) {
                    Spacer()
                    Text("RYDEN")
                        .foregroundColor(appColor)
                        .fontWeight(.heavy)
                        .font(.subheadline)
                    Spacer()
                }
                    .background(Color.white)
                
                ZStack(alignment: .top) {
                    FeedViewHeader(
                        user: userState.userInfo,
                        height: self.height - min(0, self.scrollViewContentOffset / 3)
                    )
                        .zIndex(2)
                    
                    TrackableScrollView(.vertical, showIndicators: false, contentOffset: $scrollViewContentOffset) {
                        VStack(spacing: 0) {
                            ForEach(self.feedData!.results) { workout in
                                WorkoutView(user: self.userState.userInfo, workout: workout, showUserInfo: false)
                                    .background(Color.white)
                                    .padding(.top)
                            }
                        }
                        .padding(.top, height)
                    }
                }
            } else {
                Spacer()
                HStack {
                    Spacer()
                    Text("There's nothing in your feed!")
                    Spacer()
                }
                Spacer()
            }
        }
        .background(self.feedData == nil ? Color.white : feedColor)
        .onAppear {
            self.workoutAPI.getUserWorkouts { (response) in
                self.feedData = response
            }
        }
    }
}

struct FeedViewHeader: View {
    @EnvironmentObject var routeState: RouteState
    
    var user: User?
    var height: CGFloat = 70
    var offset: CGPoint = CGPoint.zero
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            HStack(alignment: .center) {
                Spacer()
                
                UserIconShape()
                    .fill(Color.gray)
                    .padding()
                    .background(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 65, height: 65)
                    .padding(.trailing)
                
                VStack(alignment: .leading) {
                    Text(self.user?.getUserName() ?? "")
                        .font(.headline)
                        .foregroundColor(Color.gray)
                }
                
                Spacer()
            }
            
            Spacer()
            
            HStack(alignment: .center) {
                Spacer()
                
                Button(action: { self.routeState.current = .userFeed }) {
                    HeartIconShape()
                        .fill(self.routeState.current == .userFeed ? appColor : Color.gray)
                        .frame(width: 20, height: 20)
                }
                
                Spacer()
                Spacer()
                
                Button(action: { self.routeState.current = .userMetrics }) {
                    ChartIconShape()
                        .fill(self.routeState.current == .userMetrics ? appColor : Color.gray)
                        .frame(width: 20, height: 20)
                }
                
                Spacer()
            }
                .padding(.bottom)
            
            Divider()
        }
            .background(Color.white)
            .frame(height: height)
    }
}

#if DEBUG
struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        return FeedView()
            .environmentObject(UserState())
            .environmentObject(EditableWorkoutState())
            .environmentObject(RouteState(current: .userFeed))
            .environmentObject(MockWorkoutAPI(userState: UserState()) as WorkoutAPI)
    }
}
#endif
