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
    let data: ExerciseTemplateData
    let circuitID: Int?
    let circuitRounds: Int
    let exerciseDictionaries: [ExerciseDictionary]
    
    init(
        id: Int? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil,
        data: ExerciseTemplateData = ExerciseTemplateData(isSetsFieldEnabled: false, isRepsFieldEnabled: false, isWeightFieldEnabled: false, isTimeFieldEnabled: false, isDistanceFieldEnabled: false),
        circuitID: Int? = nil,
        circuitRounds: Int = 1,
        exerciseDictionaries: [ExerciseDictionary] = []
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
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
        case id, data
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

class ExerciseTemplateData: ObservableObject, Codable {
    @Published var isSetsFieldEnabled: Bool = false
    @Published var isRepsFieldEnabled: Bool = false
    @Published var isWeightFieldEnabled: Bool = false
    @Published var isTimeFieldEnabled: Bool = false
    @Published var isDistanceField: Bool = false
    
    @Published var defaultValueSets: Int = 3
    @Published var defaultValueReps: Int = 5
    @Published var defaultValueWeight: Float = 25
    @Published var defaultValueTime: Int = 0
    @Published var defaultValueDistance: Float = 0
    
    @Published var sets: Int = 0
    @Published var reps: [Int] = []
    @Published var weight: [Float] = []
    @Published var time: [Int] = []
    @Published var distance: [Float] = []
    
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
        isSetsFieldEnabled: Bool = false,
        isRepsFieldEnabled: Bool = false,
        isWeightFieldEnabled: Bool = false,
        isTimeFieldEnabled: Bool = false,
        isDistanceFieldEnabled: Bool = false
    ) {
        self.isSetsFieldEnabled = isSetsFieldEnabled
        self.isRepsFieldEnabled = isRepsFieldEnabled
        self.isWeightFieldEnabled = isWeightFieldEnabled
        self.isTimeFieldEnabled = isTimeFieldEnabled
        self.isDistanceField = isDistanceFieldEnabled
        
        self.sets = self.defaultValueSets
        self.reps = [Int](repeating: defaultValueReps, count: defaultValueSets)
        self.weight = [Float](repeating: defaultValueWeight, count: defaultValueSets)
        self.time = [Int](repeating: defaultValueTime, count: defaultValueSets)
        self.distance = [Float](repeating: defaultValueDistance, count: defaultValueSets)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        isSetsFieldEnabled = try container.decode(Bool.self, forKey: .sets)
        isRepsFieldEnabled = try container.decode(Bool.self, forKey: .reps)
        isWeightFieldEnabled = try container.decode(Bool.self, forKey: .weight)
        isTimeFieldEnabled = try container.decode(Bool.self, forKey: .time)
        isDistanceField = try container.decode(Bool.self, forKey: .distance)
        
        defaultValueSets = try container.decode(Int.self, forKey: .defaultValueSets)
        defaultValueReps = try container.decode(Int.self, forKey: .defaultValueReps)
        defaultValueWeight = try container.decode(Float.self, forKey: .defaultValueWeight)
        defaultValueTime = try container.decode(Int.self, forKey: .defaultValueTime)
        defaultValueDistance = try container.decode(Float.self, forKey: .defaultValueDistance)
        
        reps = try container.decode([Int].self, forKey: .setsDataForReps)
        weight = try container.decode([Float].self, forKey: .setsDataForWeight)
        time = try container.decode([Int].self, forKey: .setsDataForTime)
        distance = try container.decode([Float].self, forKey: .setsDataForDistance)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(isSetsFieldEnabled, forKey: .sets)
        try container.encode(isRepsFieldEnabled, forKey: .reps)
        try container.encode(isWeightFieldEnabled, forKey: .weight)
        try container.encode(isTimeFieldEnabled, forKey: .time)
        try container.encode(isDistanceField, forKey: .distance)
        
        try container.encode(defaultValueSets, forKey: .defaultValueSets)
        try container.encode(defaultValueReps, forKey: .defaultValueReps)
        try container.encode(defaultValueWeight, forKey: .defaultValueWeight)
        try container.encode(defaultValueTime, forKey: .defaultValueTime)
        try container.encode(defaultValueDistance, forKey: .defaultValueDistance)
        
        try container.encode(reps, forKey: .setsDataForReps)
        try container.encode(weight, forKey: .setsDataForWeight)
        try container.encode(time, forKey: .setsDataForTime)
        try container.encode(distance, forKey: .setsDataForDistance)
    }
    
    func isActive(field: ExerciseField) -> Bool {
        switch field {
        case .sets: return isSetsFieldEnabled
        case .reps: return isRepsFieldEnabled
        case .weight: return isWeightFieldEnabled
        case .distance: return isDistanceField
        case .time: return isTimeFieldEnabled
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
