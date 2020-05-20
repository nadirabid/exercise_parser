//
//  SubscribedFeedView.swift
//  client
//
//  Created by Nadir Muzaffar on 5/6/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Alamofire
import Combine
import SwiftUI

struct SubscriptionFeedView: View {
    @EnvironmentObject var route: RouteState
    @EnvironmentObject var workoutAPI: WorkoutAPI
    @EnvironmentObject var userAPI: UserAPI
    
    @State private var feedDataRequest: DataRequest? = nil
    @State private var feedData: PaginatedResponse<Workout>? = nil
    @State private var workouts: [Workout] = []
    @State private var workoutsPage: Int = 0
    
    @State private var users: Set<User> = []
    
    func getUserFor(workout: Workout) -> User? {
        return users.first(where: { $0.id == workout.userID })
    }
    
    func updateUsers(users: [User]) {
        for user in users {
            self.users.insert(user)
        }
    }
    
    func handleWorkoutAppear(workout: Workout) {
        if let feedData = feedData {
            if workoutsPage == feedData.pages! - 1 {
                return
            }
            
            let indexOfWorkout = workouts.firstIndex(where: { $0.id! == workout.id! })
            if indexOfWorkout == nil {
                print("How the fuck are we displaying something not in the list!")
                return
            }
            
            if indexOfWorkout! >= workouts.count - 1 {
                if feedDataRequest != nil {
                    print("Data request already in progress!")
                    return
                }
                
                self.feedDataRequest = self.workoutAPI.getUserSubscriptionWorkouts(page: workoutsPage + 1, pageSize: 20) { (response) in
                    self.feedData = response
                    self.workoutsPage = response.page!
                    self.workouts.append(contentsOf: response.results)
                    self.feedDataRequest = nil
                    
                    let userIDs = Set<Int>(
                        response.results
                            .filter({ (workout) -> Bool in
                                return !self.users.contains(where: { $0.id == workout.userID })
                            })
                            .map({ $0.userID })
                        )
                    
                    if userIDs.count == 0 {
                        return
                    }
                    
                    self.userAPI.getUsersByIDs(users: userIDs) { (response) in
                        self.updateUsers(users: response.results)
                    }
                }
            }
        }
    }
    
    var body: some View {
        UITableView.appearance().separatorColor = .clear
        
        return VStack {
            if self.feedData == nil {
                Spacer()
                HStack {
                    Spacer()
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                    Spacer()
                }
                Spacer()
            } else if workouts.count > 0  {
                List {
                    ForEach(workouts) { workout in
                        WorkoutView(user: self.getUserFor(workout: workout), workout: workout)
                            .background(Color.white)
                            .padding(.top)
                            .buttonStyle(PlainButtonStyle())
                            .animation(.none)
                            .onAppear {
                                self.handleWorkoutAppear(workout: workout)
                            }
                    }
                    .listRowInsets(EdgeInsets())
                    .background(self.feedData == nil ? Color.white : feedColor)
                    .animation(.none)
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
            self.feedDataRequest = self.workoutAPI.getUserSubscriptionWorkouts(page: 0, pageSize: 20) { (response) in
                self.feedDataRequest = nil
                self.feedData = response
                self.workoutsPage = response.page!
                self.workouts.append(contentsOf: response.results)
                
                let userIDs = Set<Int>(response.results.map { $0.userID })
                self.userAPI.getUsersByIDs(users: userIDs) { (response) in
                    self.updateUsers(users: response.results)
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
