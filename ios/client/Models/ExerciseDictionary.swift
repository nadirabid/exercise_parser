//
//  ExerciseDictionary.swift
//  client
//
//  Created by Nadir Muzaffar on 4/27/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation

struct ExerciseDictionary: Identifiable, Codable {
    let id: Int?
    let name: String
    let muscles: ExerciseDictionaryMuscles
}

struct ExerciseDictionaryMuscles: Codable {
    let target: [String]?
    let synergists: [String]?
    let stabilizers: [String]?
    let dynamicStabilizers: [String]?
    let antagonistStabilizers: [String]?
    
    enum CodingKeys: String, CodingKey {
        case dynamicStabilizers = "dynamic_stabilizers"
        case antagonistStabilizers = "antagonist_stabilizers"
        case target, synergists, stabilizers
    }
}
