//
//  Workout.swift
//  client
//
//  Created by Nadir Muzaffar on 6/23/19.
//  Copyright © 2019 Nadir Muzaffar. All rights reserved.
//

import Foundation
import SwiftUI
import MapKit

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
    let inProgress: Bool
    
    init(
        id: Int? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil,
        name: String = "",
        date: Date = Date(),
        exercises: [Exercise] = [],
        userID: Int = 0,
        location: Location? = nil,
        secondsElapsed: Int = 0,
        inProgress: Bool = false
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
        self.inProgress = inProgress
    }
    
    var isRunWorkout: Bool {
        if exercises.count == 1 && exercises.first!.locations.count > 0 {
            return true
        }
        
        return false
    }
    
    func hasAtleastOneResolvedExercises() -> Bool {
        return exercises.contains(where: { e in ExerciseResolutionType.isConsideredResolved(resolutionType: e.resolutionType) })
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
        case inProgress = "in_progress"
        case id, name, date, exercises, location
    }
}

struct Location: Codable {
    let latitude: Double
    let longitude: Double
    let exerciseID: Int?
    let index: Int?
    
    init(
        latitude: Double = 0,
        longitude: Double = 0,
        exerciseID: Int? = nil,
        index: Int? = nil
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.exerciseID = exerciseID
        self.index = index
    }
    
    init(coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.exerciseID = nil
        self.index = nil
    }

    private enum CodingKeys: String, CodingKey {
        case exerciseID = "exercise_id"
        case latitude, longitude, index
    }
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
    let circuitID: Int?
    let circuitRounds: Int
    let locations: [Location]
    
    init(
        id: Int? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil,
        name: String = "",
        type: String = "",
        raw: String = "",
        resolutionType: String = "",
        data: ExerciseData = ExerciseData(sets: 0, reps: 0, weight: 0, time: 0, distance: 0),
        correctiveCode: Int = 0,
        circuitID: Int? = nil,
        circuitRounds: Int = 1,
        locations: [Location] = []
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
        self.circuitID = circuitID
        self.circuitRounds = circuitRounds
        self.locations = locations
    }
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case resolutionType = "resolution_type"
        case correctiveCode = "corrective_code"
        case circuitID = "circuit_id"
        case circuitRounds = "circuit_rounds"
        case id, name, type, raw, data, locations
    }
}

enum ExerciseResolutionType: String {
    case AutoSingleResolutionType = "auto.single"
    case AutoCompoundResolutionType = "auto.compound"
    case AutoRunTracker = "auto.run_tracker"
    case AutoSpecialRestResolutionType = "auto.special.rest"
    case ManualSingleResolutionType = "manual.single"
    case FailedPermanentlyResolutionType = "failed.permanently"
}

extension ExerciseResolutionType {
    static func isConsideredResolved(resolutionType: String) -> Bool {
        switch resolutionType {
        case AutoSingleResolutionType.rawValue,
             AutoCompoundResolutionType.rawValue,
             AutoRunTracker.rawValue,
             AutoSpecialRestResolutionType.rawValue,
             ManualSingleResolutionType.rawValue:
             return true
        default:
            return false
        }
    }
}

enum ExerciseCorrectiveCode: Int, CaseIterable {
    case Unknown = -1
    case None = 0
    case MissingExercise = 1
    case MissingQuantity = 2
    case MissingExerciseAndReps = 3
    case UndeterminableUnitsSetOrWeight = 4
}

extension ExerciseCorrectiveCode {
    var message: String {
        switch self {
        case .None: return "Processed exercise successfully"
        case .MissingExercise: return "Add the exercise name"
        case .MissingQuantity: return "Add quantity (eg. time, sets, reps and/or distance)"
        case .MissingExerciseAndReps: return "Add exercise and reps"
        case .UndeterminableUnitsSetOrWeight: return "Can't figure out if you meant weight or sets"
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
    
    var pace: Double {
        if time == 0 {
            return 0
        }
        
        if distance == 0 {
            return 0
        }
        
        let durationMeasurement = Measurement(value: Double(time), unit: UnitDuration.seconds).converted(to: UnitDuration.minutes)
        let distanceMeasurement = Measurement(value: Double(distance), unit: UnitLength.meters).converted(to: UnitLength.miles)
        
        return durationMeasurement.value / distanceMeasurement.value
    }
}

