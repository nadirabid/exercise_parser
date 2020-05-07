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
    @EnvironmentObject var route: RouteState
    @EnvironmentObject var workoutAPI: WorkoutAPI
    @State private var feedDataPublisher: AnyCancellable? = nil
    @State private var feedData: PaginatedResponse<Workout>? = nil
        
    var body: some View {
        return VStack {
            if self.feedData == nil {
                Spacer()
                HStack {
                    Spacer()
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                    Spacer()
                }
                Spacer()
            } else if self.feedData != nil && self.feedData?.results.count ?? 0 > 0  {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(self.feedData!.results) { workout in
                            WorkoutView(user: self.userState.userInfo, workout: workout)
                                .background(Color.white)
                                .padding(.top)
                        }
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

#if DEBUG
struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        return FeedView()
            .environmentObject(UserState())
            .environmentObject(EditableWorkoutState())
            .environmentObject(RouteState(current: .feed))
            .environmentObject(MockWorkoutAPI(userState: UserState()) as WorkoutAPI)
    }
}
#endif
