//
//  Workout.swift
//  client
//
//  Created by Nadir Muzaffar on 6/23/19.
//  Copyright © 2019 Nadir Muzaffar. All rights reserved.
//

import Foundation
import SwiftUI

struct Workout: Codable, Identifiable {
    let id: Int?
    let createdAt: String?
    let updatedAt: String?
    let name: String
    let date: Date
    let exercises: [Exercise]
    let userID: Int?
    let location: Location?
    let secondsElapsed: Int
    
    init(
        id: Int? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil,
        name: String = "",
        date: Date = Date(),
        exercises: [Exercise] = [],
        userID: Int? = nil,
        location: Location? = nil,
        secondsElapsed: Int = 0
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        self.date = date
        self.exercises = exercises
        self.userID = userID
        self.location = location
        self.secondsElapsed = secondsElapsed
    }
    
    private enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userID = "user_id"
        case secondsElapsed = "seconds_elapsed"
        case id, name, date, exercises, location
    }
}

struct Location: Codable {
    let latitude: Double
    let longitude: Double
}

enum ExerciseType: String {
    case distance = "distance"
    case weighted = "weighted"
    case unknown = "unknown"
}

struct Exercise: Codable, Identifiable {
    let id: Int?
    let createdAt: String?
    let updatedAt: String?
    let name: String
    let type: String
    let raw: String
    let weightedExercise: WeightedExercise?
    let distanceExercise: DistanceExercise?
    
    init(
        name: String,
        type: String,
        raw: String,
        weightedExercise: WeightedExercise? = nil,
        distanceExercise: DistanceExercise? = nil
    ) {
        self.id = nil
        self.createdAt = nil
        self.updatedAt = nil
        self.name = name
        self.type = type
        self.raw = raw
        self.weightedExercise = weightedExercise
        self.distanceExercise = distanceExercise
    }
    
    init(
        id: Int? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil,
        name: String = "",
        type: String = "unknown",
        raw: String = "",
        weightedExercise: WeightedExercise? = nil,
        distanceExercise: DistanceExercise? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        self.type = type
        self.raw = raw
        self.weightedExercise = weightedExercise
        self.distanceExercise = distanceExercise
    }
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case weightedExercise = "weighted_exercise"
        case distanceExercise = "distance_exercise"
        case id, name, type, raw
    }
}

struct WeightedExercise: Codable {
    let sets: Int
    let reps: Int
    let weight: Float32
}

struct DistanceExercise: Codable {
    let time: Int
    let distance: Float32
}
