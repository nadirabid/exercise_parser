//
//  AppState.swift
//  client
//
//  Created by Nadir Muzaffar on 3/7/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class UserActivity: ObservableObject {
    var id = UUID()
    @Published var input: String
    @Published var exercise: Exercise?
    var dataTaskPublisher: AnyCancellable?
    
    init(input: String) {
        self.input = input
    }
    
    init(input: String, dataTaskPublisher: AnyCancellable?, exercise: Exercise?) {
        self.input = input
        self.dataTaskPublisher = dataTaskPublisher
        self.exercise = exercise
    }
}

class WorkoutEditorState: ObservableObject {
    @Published var newEntry: String = ""
    @Published var workoutName: String = ""
    @Published var activities: [UserActivity] = []
    @Published var isStopped = false
    var dataTaskPublisher: AnyCancellable? = nil
    var anyCancellable: AnyCancellable? = nil
    
    func reset() {
        self.newEntry = ""
        self.workoutName = ""
        self.activities = []
        self.isStopped = false
        self.dataTaskPublisher = nil
    }
}

class RouteState: ObservableObject {
    @Published var current: Route
    
    init(current: Route = .editor) {
        self.current = current
    }
    
    enum Route {
        case feed
        case editor
    }
}
