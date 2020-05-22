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

class ExerciseEditState: ObservableObject {
    var id = UUID()
    @Published var input: String
    @Published var exercise: Exercise?
    
    init(input: String) {
        self.input = input
    }
    
    init(exercise: Exercise) {
        self.input = exercise.name
        self.exercise = exercise
    }
    
    init(input: String, exercise: Exercise?) {
        self.input = input
        self.exercise = exercise
    }
}

class WorkoutCreateState: ObservableObject {
    @Published var newEntry: String = ""
    @Published var workoutName: String = ""
    @Published var exerciseStates: [ExerciseEditState] = []
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
