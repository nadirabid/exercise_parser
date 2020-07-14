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

class ExerciseTemplateDataFields: ObservableObject, Codable {
    @Published var sets: Bool = false
    @Published var reps: Bool = false
    @Published var weight: Bool = false
    @Published var time: Bool = false
    @Published var distance: Bool = false
    
    @Published var defaultValueSets: Int = 3
    @Published var defaultValueReps: Int = 5
    @Published var defaultValueWeight: Float = 25
    @Published var defaultValueTime: Int = 0
    @Published var defaultValueDistance: Float = 0
    
    @Published var setsDataForReps: [Int] = []
    @Published var setsDataForWeight: [Float] = []
    @Published var setsDataForTime: [Int] = []
    @Published var setsDataForDistance: [Float] = []
    
    enum CodingKeys: String, CodingKey {
        case defaultValueSets = "default_value_sets"
        case defaultValueReps = "default_value_reps"
        case defaultValueWeight = "default_value_weight"
        case defaultValueTime = "default_value_time"
        case defaultValueDistance = "default_value_distance"
        case setsDataForReps = "sets_data_for_reps"
        case setsDataForWeight = "sets_data_for_weight"
        case setsDataForTime = "sets_data_for_time"
        case setsDataForDistance = "sets_data_for_distance"
        case sets, reps, weight, time, distance
    }
    
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
        
        self.setsDataForReps = [Int](repeating: defaultValueReps, count: defaultValueSets)
        self.setsDataForWeight = [Float](repeating: defaultValueWeight, count: defaultValueSets)
        self.setsDataForTime = [Int](repeating: defaultValueTime, count: defaultValueSets)
        self.setsDataForDistance = [Float](repeating: defaultValueDistance, count: defaultValueSets)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        sets = try container.decode(Bool.self, forKey: .sets)
        reps = try container.decode(Bool.self, forKey: .reps)
        weight = try container.decode(Bool.self, forKey: .weight)
        time = try container.decode(Bool.self, forKey: .time)
        distance = try container.decode(Bool.self, forKey: .distance)
        
        defaultValueSets = try container.decode(Int.self, forKey: .defaultValueSets)
        defaultValueReps = try container.decode(Int.self, forKey: .defaultValueReps)
        defaultValueWeight = try container.decode(Float.self, forKey: .defaultValueWeight)
        defaultValueTime = try container.decode(Int.self, forKey: .defaultValueTime)
        defaultValueDistance = try container.decode(Float.self, forKey: .defaultValueDistance)
        
        setsDataForReps = try container.decode([Int].self, forKey: .setsDataForReps)
        setsDataForWeight = try container.decode([Float].self, forKey: .setsDataForWeight)
        setsDataForTime = try container.decode([Int].self, forKey: .setsDataForTime)
        setsDataForDistance = try container.decode([Float].self, forKey: .setsDataForDistance)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(sets, forKey: .sets)
        try container.encode(reps, forKey: .reps)
        try container.encode(weight, forKey: .weight)
        try container.encode(time, forKey: .time)
        try container.encode(distance, forKey: .distance)
        
        try container.encode(defaultValueSets, forKey: .defaultValueSets)
        try container.encode(defaultValueReps, forKey: .defaultValueReps)
        try container.encode(defaultValueWeight, forKey: .defaultValueWeight)
        try container.encode(defaultValueTime, forKey: .defaultValueTime)
        try container.encode(defaultValueDistance, forKey: .defaultValueDistance)
        
        try container.encode(setsDataForReps, forKey: .setsDataForReps)
        try container.encode(setsDataForWeight, forKey: .setsDataForWeight)
        try container.encode(setsDataForTime, forKey: .setsDataForTime)
        try container.encode(setsDataForDistance, forKey: .setsDataForDistance)
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
