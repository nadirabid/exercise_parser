//
//  Metrics.swift
//  client
//
//  Created by Nadir Muzaffar on 5/11/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation

struct MuscleStat: Codable {
    let muscle: String
    let reps: Int
}

struct MetricsTopLevel: Codable {
    let distance: Float
    let sets: Int
    let reps: Int
    let secondsElapsed: Int
    let calories: Int
    
    enum CodingKeys: String, CodingKey {
        case secondsElapsed = "seconds_elapsed"
        case sets, reps, distance, calories
    }
}

struct MetricMuscle: Codable {
    let name: String
    let usage: String
    let reps: Int
}

struct Metric: Codable {
    let muscles: [MetricMuscle]
    let topLevel: MetricsTopLevel
    
    enum CodingKeys: String, CodingKey {
        case topLevel = "top_level"
        case muscles
    }
}
