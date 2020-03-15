//
//  AppState.swift
//  client
//
//  Created by Nadir Muzaffar on 3/7/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation
import Combine

class WorkoutEditorState: ObservableObject {
    @Published var newEntry: String = ""
    @Published var workoutName: String = "No name"
    @Published var activities: [UserActivity] = []
    @Published var isStopped = false
    var dataTaskPublisher: AnyCancellable? = nil
    
    func reset() {
        self.newEntry = ""
        self.workoutName = "No name"
        self.activities = []
        self.isStopped = false
        self.dataTaskPublisher = nil
    }
}

class RouteState: ObservableObject {
    @Published var current: Route
    
    init(current: Route = .feed) {
        self.current = current
    }
    
    enum Route {
        case feed
        case editor
    }
}

class UserState: ObservableObject {
    // 1 = Authorized, -1 = Revoked
    @Published var authorization: Int = 0
    @Published var token: String? = nil
}
