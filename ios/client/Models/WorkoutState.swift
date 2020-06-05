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

class ExerciseEditState: ObservableObject, Equatable {
    var id = UUID()
    
    @Published var input: String
    @Published var exercise: Exercise?
    
    @Published var circuitID: Int? = nil
    @Published var circuitRounds: Int = 1
    
    init(input: String) {
        self.input = input
    }
    
    init(input: String, circuitID: Int) {
        self.input = input
        self.circuitID = circuitID
    }
    
    init(exercise: Exercise) {
        self.input = exercise.raw
        self.exercise = exercise
    }
    
    init(input: String, exercise: Exercise?) {
        self.input = input
        self.exercise = exercise
    }
    
    static func == (lhs: ExerciseEditState, rhs: ExerciseEditState) -> Bool {
        lhs.id == rhs.id
    }
}

class WorkoutCreateState: ObservableObject {
    @Published var newEntry: String = ""
    @Published var workoutName: String = ""
    @Published var exerciseStates: [ExerciseEditState] = [
        ExerciseEditState(input: "3x3 tricep curls")
    ]
    @Published var isStopped = false
    
    var date: Date = Date()
    
    func reset() {
        self.newEntry = ""
        self.workoutName = ""
        self.exerciseStates = []
        self.isStopped = false
        self.date = Date()
    }
}

class UserFeedState: ObservableObject {
    @Published var workouts: Set<Workout>
    
    init() {
        workouts = Set()
    }
}
