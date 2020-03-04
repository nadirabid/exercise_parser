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
    let id: Int
    let createdAt: String
    let updatedAt: String
    let name: String
    let date: String
    let exercises: [Exercise]
    
    private enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case id, name, date, exercises
    }
}

struct Exercise: Codable, Identifiable {
    let id: Int
    let createdAt: String
    let updatedAt: String
    let name: String
    let type: String
    let raw: String
    let weightedExercise: WeightedExercise?
    let distanceExercise: DistanceExercise?
    
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
}

struct DistanceExercise: Codable {
    let time: String
    let distance: Float32
    let units: String
}
