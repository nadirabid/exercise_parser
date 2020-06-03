//
//  Workout.swift
//  client
//
//  Created by Nadir Muzaffar on 6/23/19.
//  Copyright © 2019 Nadir Muzaffar. All rights reserved.
//

import Foundation
import SwiftUI

struct Workout: Codable, Identifiable, Hashable {
    let id: Int?
    let createdAt: String?
    let updatedAt: String?
    let name: String
    let date: Date
    let exercises: [Exercise]
    let userID: Int
    let location: Location?
    let secondsElapsed: Int
    
    init(
        id: Int? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil,
        name: String = "",
        date: Date = Date(),
        exercises: [Exercise] = [],
        userID: Int = 0,
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
    
    func hasAtleastOneResolvedExercises() -> Bool {
        return exercises.contains(where: { e in e.type != "" })
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    static func == (lhs: Workout, rhs: Workout) -> Bool {
        return lhs.id == rhs.id
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
    let data: ExerciseData
    let resolutionType: String
    let correctiveCode: Int
    
    init(raw: String, correctiveCode: Int) {
        self.id = nil
        self.createdAt = nil
        self.updatedAt = nil
        self.name = ""
        self.type = ""
        self.raw = raw
        self.data = ExerciseData(sets: 0, reps: 0, weight: 0, time: 0, distance: 0)
        self.resolutionType = ""
        self.correctiveCode = correctiveCode
    }
    
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
        self.data = data
        self.resolutionType = ""
        self.correctiveCode = 0
    }
    
    init(
        id: Int? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil,
        name: String = "",
        type: String = "",
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
        self.resolutionType = resolutionType
        self.data = data
        self.correctiveCode = 0
    }
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case resolutionType = "resolution_type"
        case correctiveCode = "corrective_code"
        case id, name, type, raw, data
    }
}

enum ExerciseCorrectiveCode: Int, CaseIterable {
    case Unknown = -1
    case None = 0
    case MissingExercise = 1
    case MissingQuantity = 2
    case MissingExerciseAndReps = 3
}

extension ExerciseCorrectiveCode {
    var message: String {
        switch self {
        case .None: return "Processed exercise successfully"
        case .MissingExercise: return "Add the exercise name"
        case .MissingQuantity: return "Add quantity (eg. time, sets, reps and/or distance)"
        case .MissingExerciseAndReps: return "Add exercise and reps"
        case .Unknown: return "No idea"
        }
    }
    
    static func from(code: Int) -> ExerciseCorrectiveCode {
        let value = ExerciseCorrectiveCode.allCases.first(where: {$0.rawValue == code})
        if let v = value {
            return v
        }
        
        return .Unknown
    }
}

struct ExerciseData: Codable {
    let sets: Int
    let reps: Int
    let weight: Float
    let time: Int
    let distance: Float
    
    var displayWeightUnits: String {
        return UnitMass.pounds.symbol
    }
    
    var displayWeightValue: Float {
        let m = Measurement(value: Double(weight), unit: UnitMass.kilograms).converted(to: UnitMass.pounds)
        return Float(m.value)
    }
    
    var displayDistanceUnits: String {
        if distance <= 300 {
            return UnitLength.feet.symbol
        }
        
        return UnitLength.miles.symbol
    }
    
    var displayDistanceValue: Float {
        var m = Measurement(value: Double(distance), unit: UnitLength.meters)
        
        if distance <= 300 {
            m = m.converted(to: UnitLength.feet)
        } else {
            m = m.converted(to: UnitLength.miles)
        }
        
        return Float(round(m.value*100)/100)
    }
}
