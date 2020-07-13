//
//  WorkoutTemplate.swift
//  client
//
//  Created by Nadir Muzaffar on 7/7/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation

struct WorkoutTemplate: Codable, Identifiable, Hashable {
    let id: Int?
    let createdAt: String?
    let updatedAt: String?
    let name: String
    let exercises: [ExerciseTemplate]
    let userID: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    static func == (lhs: WorkoutTemplate, rhs: WorkoutTemplate) -> Bool {
        return lhs.id == rhs.id
    }
    
    private enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userID = "user_id"
        case id, name, exercises
    }
}

struct ExerciseTemplate: Codable, Identifiable {
    let id: Int?
    let cid: UUID = UUID()
    let createdAt: String?
    let updatedAt: String?
    let name: String
    let data: ExerciseTemplateDataFields
    let circuitID: Int?
    let circuitRounds: Int
    let exerciseDictionaries: [ExerciseDictionary]
    
    init(
        id: Int? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil,
        name: String = "",
        data: ExerciseTemplateDataFields = ExerciseTemplateDataFields(sets: false, reps: false, weight: false, time: false, distance: false),
        circuitID: Int? = nil,
        circuitRounds: Int = 1,
        exerciseDictionaries: [ExerciseDictionary] = []
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        self.data = data
        self.circuitID = circuitID
        self.circuitRounds = circuitRounds
        self.exerciseDictionaries = exerciseDictionaries
    }
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case circuitID = "circuit_id"
        case circuitRounds = "circuit_rounds"
        case exerciseDictionaries = "exercise_dictionaries"
        case id, name, data
    }
}

enum ExerciseField: String {
    case sets
    case reps
    case weight
    case distance
    case time
    
    var description: String {
        switch self {
        case .sets: return "sets"
        case .reps: return "reps"
        case .weight: return "weight"
        case .distance: return "distance"
        case .time: return "time"
        }
    }
}

struct ExerciseTemplateDataFields: Codable {
    let sets: Bool
    let reps: Bool
    let weight: Bool
    let time: Bool
    let distance: Bool
    
    let defaultValueSets: Int
    let defaultValueReps: Int
    let defaultValueWeight: Float
    let defaultValueTime: Int
    let defaultValueDistance: Float
    
    init(
        sets: Bool = false,
        reps: Bool = false,
        weight: Bool = false,
        time: Bool = false,
        distance: Bool = false
    ) {
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.time = time
        self.distance = distance
        
        self.defaultValueSets = 3
        self.defaultValueReps = 5
        self.defaultValueWeight = 25
        self.defaultValueTime = 0
        self.defaultValueDistance = 0
    }
    
    func isActive(field: ExerciseField) -> Bool {
        switch field {
        case .sets: return sets
        case .reps: return reps
        case .weight: return weight
        case .distance: return distance
        case .time: return time
        }
    }
    
    func defaultValueFor(field: ExerciseField) -> String {
        switch field {
        case .sets:
            return "\(defaultValueSets)"
        case .reps:
            return "\(defaultValueReps)"
        case .weight:
            return "\(defaultValueWeight)"
        case .distance:
            return "\(defaultValueDistance)"
        case .time:
            return "\(defaultValueTime)"
        }
    }
}
