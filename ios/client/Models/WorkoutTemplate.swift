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
    let userID: Int?
    let isNotTemplate: Bool
    let secondsElapsed: Int
    
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
        case exercises = "exercise_templates"
        case isNotTemplate = "is_not_template"
        case secondsElapsed = "seconds_elapsed"
        case id, name
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
    case calories
    
    var description: String {
        switch self {
        case .sets: return ""
        case .reps: return "reps"
        case .weight: return "lbs"
        case .distance: return "mi"
        case .time: return "time"
        case .calories: return "cal"
        }
    }
}

class ExerciseTemplateData: ObservableObject, Codable {
    @Published var isSetsFieldEnabled: Bool = false
    @Published var isRepsFieldEnabled: Bool = false
    @Published var isWeightFieldEnabled: Bool = false
    @Published var isTimeFieldEnabled: Bool = false
    @Published var isDistanceFieldEnabled: Bool = false
    @Published var isCaloriesFieldEnabled: Bool = false
    
    @Published var fieldWeightUnits: String = UnitMass.pounds.symbol
    @Published var fieldTimeUnits: String = UnitDuration.seconds.symbol
    @Published var fieldDistanceUnits: String = UnitLength.feet.symbol
    
    @Published var defaultValueSets: Int = 3
    @Published var defaultValueReps: Int = 5
    @Published var defaultValueWeight: Float = 25 // units are stored as kilograms
    @Published var defaultValueTime: Int = 60 // stores as seconds
    @Published var defaultValueDistance: Float = 0 // stored as meters
    @Published var defaultValueCalories: Int = 0
    @Published var defaultValueComplete: Bool = false
    
    @Published var sets: Int = 0
    @Published var reps: [Int] = []
    @Published var weight: [Float] = []
    @Published var time: [Int] = []
    @Published var distance: [Float] = []
    @Published var calories: [Int] = []
    @Published var completedSets: [Bool] = []
    
    enum CodingKeys: String, CodingKey {
        case defaultValueSets = "default_value_sets"
        case defaultValueReps = "default_value_reps"
        case defaultValueWeight = "default_value_weight"
        case defaultValueTime = "default_value_time"
        case defaultValueDistance = "default_value_distance"
        case defaultValueCalories = "default_value_calories"
        case isSetsFieldEnabled = "is_sets_field_enabled"
        case isRepsFieldEnabled = "is_reps_field_enabled"
        case isWeightFieldEnabled = "is_weight_field_enabled"
        case isTimeFieldEnabled = "is_time_field_enabled"
        case isDistanceFieldEnabled = "is_distance_field_enabled"
        case isCaloriesFieldEnabled = "is_calories_field_enabled"
        case sets, reps, weight, time, distance, calories, complete
    }
    
    init(
        isSetsFieldEnabled: Bool = false,
        isRepsFieldEnabled: Bool = false,
        isWeightFieldEnabled: Bool = false,
        isTimeFieldEnabled: Bool = false,
        isDistanceFieldEnabled: Bool = false,
        isCaloriesFieldEnabled: Bool = false
    ) {
        self.isSetsFieldEnabled = isSetsFieldEnabled
        self.isRepsFieldEnabled = isRepsFieldEnabled
        self.isWeightFieldEnabled = isWeightFieldEnabled
        self.isTimeFieldEnabled = isTimeFieldEnabled
        self.isDistanceFieldEnabled = isDistanceFieldEnabled
        self.isCaloriesFieldEnabled = isCaloriesFieldEnabled
        
        self.sets = self.isSetsFieldEnabled ? self.defaultValueSets : 1
        self.reps = [Int](repeating: defaultValueReps, count: defaultValueSets)
        self.weight = [Float](repeating: defaultValueWeight, count: defaultValueSets)
        self.time = [Int](repeating: defaultValueTime, count: defaultValueSets)
        self.distance = [Float](repeating: defaultValueDistance, count: defaultValueSets)
        self.calories = [Int](repeating: defaultValueCalories, count: defaultValueSets)
        self.completedSets = [Bool](repeating: defaultValueComplete, count: defaultValueSets)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        isSetsFieldEnabled = try container.decode(Bool.self, forKey: .isSetsFieldEnabled)
        isRepsFieldEnabled = try container.decode(Bool.self, forKey: .isRepsFieldEnabled)
        isWeightFieldEnabled = try container.decode(Bool.self, forKey: .isWeightFieldEnabled)
        isTimeFieldEnabled = try container.decode(Bool.self, forKey: .isTimeFieldEnabled)
        isDistanceFieldEnabled = try container.decode(Bool.self, forKey: .isDistanceFieldEnabled)
        isCaloriesFieldEnabled = try container.decode(Bool.self, forKey: .isCaloriesFieldEnabled)
        
        sets = try container.decode(Int.self, forKey: .sets)
        reps = try container.decode([Int].self, forKey: .reps)
        weight = try container.decode([Float].self, forKey: .weight)
        time = try container.decode([Int].self, forKey: .time)
        distance = try container.decode([Float].self, forKey: .distance)
        calories = try container.decode([Int].self, forKey: .calories)
        completedSets = [Bool](repeating: defaultValueComplete, count: sets)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(isSetsFieldEnabled, forKey: .isSetsFieldEnabled)
        try container.encode(isRepsFieldEnabled, forKey: .isRepsFieldEnabled)
        try container.encode(isWeightFieldEnabled, forKey: .isWeightFieldEnabled)
        try container.encode(isTimeFieldEnabled, forKey: .isTimeFieldEnabled)
        try container.encode(isDistanceFieldEnabled, forKey: .isDistanceFieldEnabled)
        try container.encode(isCaloriesFieldEnabled, forKey: .isCaloriesFieldEnabled)
        
        try container.encode(sets, forKey: .sets)
        try container.encode(reps, forKey: .reps)
        try container.encode(weight, forKey: .weight)
        try container.encode(time, forKey: .time)
        try container.encode(distance, forKey: .distance)
        try container.encode(calories, forKey: .calories)
    }
    
    func isActive(field: ExerciseField) -> Bool {
        switch field {
        case .sets: return isSetsFieldEnabled
        case .reps: return isRepsFieldEnabled
        case .weight: return isWeightFieldEnabled
        case .distance: return isDistanceFieldEnabled
        case .time: return isTimeFieldEnabled
        case .calories: return isCaloriesFieldEnabled
        }
    }
    
    func addSet() {
        self.sets += 1
        self.reps.append(self.defaultValueReps)
        self.weight.append(self.defaultValueWeight)
        self.time.append(self.defaultValueTime)
        self.distance.append(self.defaultValueDistance)
        self.calories.append(self.defaultValueCalories)
        self.completedSets.append(self.defaultValueComplete)
    }
    
    func removeSetAt(index: Int) {
        self.sets -= 1
        self.reps.remove(at: index)
        self.weight.remove(at: index)
        self.distance.remove(at: index)
        self.time.remove(at: index)
        self.calories.remove(at: index)
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
        case .calories:
            return "\(defaultValueCalories)"
        }
    }
    
    func displayTimeValue(setIndex: Int) -> Float {
        let m = Measurement(value: Double(time[setIndex]), unit: UnitDuration.seconds)
        
        if self.fieldTimeUnits == UnitDuration.seconds.symbol {
            return Float(m.value)
        } else if self.fieldTimeUnits == UnitDuration.minutes.symbol {
            return Float(m.converted(to: UnitDuration.minutes).value)
        }
        
        return 0
    }
    
    func displayWeightValue(setIndex: Int) -> Float {
        let m = Measurement(value: Double(weight[setIndex]), unit: UnitMass.kilograms)
        
        if self.fieldWeightUnits == UnitMass.pounds.symbol {
            return Float(m.converted(to: UnitMass.pounds).value)
        } else if self.fieldWeightUnits == UnitMass.kilograms.symbol {
            return Float(m.value)
        }
        
        return 0
    }
    
    func displayDistanceValue(setIndex: Int) -> Float {
        let distance = self.distance[setIndex]
        var m = Measurement(value: Double(distance), unit: UnitLength.meters)
        
        if self.fieldDistanceUnits == UnitLength.feet.symbol {
            m = m.converted(to: UnitLength.feet)
            return Float(round(m.value*100) / 200)
        } else if self.fieldDistanceUnits == UnitLength.yards.symbol {
            m = m.converted(to: UnitLength.yards)
            return Float(round(m.value*100) / 200)
        } else if self.fieldDistanceUnits == UnitLength.miles.symbol {
            m = m.converted(to: UnitLength.miles)
            return Float(round(m.value*100) / 200)
        } else if self.fieldDistanceUnits == UnitLength.meters.symbol {
            m = m.converted(to: UnitLength.meters)
            return Float(round(m.value*100) / 200)
        } else if self.fieldDistanceUnits == UnitLength.kilometers.symbol {
            m = m.converted(to: UnitLength.kilometers)
            return Float(round(m.value*100) / 200)
        }
        
        return 0
    }
}
