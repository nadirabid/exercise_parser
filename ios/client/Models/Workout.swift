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

struct Exercise: Codable, Identifiable {
    let id: Int?
    let createdAt: String?
    let updatedAt: String?
    let name: String
    let type: String
    let raw: String
    let exerciseDictionaryID: Int?
    let data: ExerciseData
    let resolutionType: String
    
    init(
        name: String,
        type: String,
        raw: String,
        data: ExerciseData = ExerciseData(sets: 0, reps: 0, weight: 0, time: 0, distance: 0)
    ) {
        self.id = nil
        self.createdAt = nil
        self.updatedAt = nil
        self.name = name
        self.type = type
        self.raw = raw
        self.exerciseDictionaryID = nil
        self.data = data
        self.resolutionType = ""
    }
    
    init(
        id: Int? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil,
        name: String = "",
        type: String = "unknown",
        raw: String = "",
        resolutionType: String = "",
        data: ExerciseData = ExerciseData(sets: 0, reps: 0, weight: 0, time: 0, distance: 0)
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        self.type = type
        self.raw = raw
        self.exerciseDictionaryID = nil
        self.resolutionType = resolutionType
        self.data = data
    }
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case exerciseDictionaryID = "exercise_dictionary_id"
        case resolutionType = "resolution_type"
        case id, name, type, raw, data
    }
}

struct ExerciseData: Codable {
    let sets: Int
    let reps: Int
    let weight: Float
    let time: Int
    let distance: Float32
    
    var displayUnitsWeight: Float {
        let m = Measurement(value: Double(weight), unit: UnitMass.kilograms).converted(to: UnitMass.pounds)
        return Float(m.value)
    }
    
    var displayUnitsDistance: Float {
        let m = Measurement(value: Double(distance), unit: UnitLength.meters).converted(to: UnitLength.miles)
        return Float(round(m.value*10)/10)
    }
}
