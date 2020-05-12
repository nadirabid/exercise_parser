//
//  SubscribedFeedView.swift
//  client
//
//  Created by Nadir Muzaffar on 5/6/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Combine
import SwiftUI

struct SubscriptionFeedView: View {
    @EnvironmentObject var route: RouteState
    @EnvironmentObject var workoutAPI: WorkoutAPI
    @EnvironmentObject var userAPI: UserAPI
    
    @State private var feedData: PaginatedResponse<Workout>? = nil
    
    @State private var feedUsersPublisher: AnyCancellable? = nil
    @State private var feedUsers: PaginatedResponse<User>? = nil
    
    func getUserFor(workout: Workout) -> User? {
        return feedUsers?.results.first(where: { $0.id == workout.userID })
    }
    
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
                            WorkoutView(user: self.getUserFor(workout: workout), workout: workout)
                                .background(Color.white)
                                .padding(.top)
                        }
                    }
                }
            } else {
                Spacer()
                HStack {
                    Spacer()
                    Text("Subscribe to some peeps!")
                    Spacer()
                }
                Spacer()
            }
        }
        .background(self.feedData == nil ? Color.white : feedColor)
        .onAppear {
            self.workoutAPI.getUserSubscriptionWorkouts { (response) in
                self.feedData = response
                
                let userIDs = Set<Int>(response.results.map { $0.userID })
                self.userAPI.getUsersByIDs(users: userIDs) { (response) in
                    self.feedUsers = response
                }
            }
        }
    }
}

struct SubscriptionFeed_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionFeedView()
    }
}
