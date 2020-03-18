//
//  Config.swift
//  client
//
//  Created by Nadir Muzaffar on 3/5/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation
import SwiftUI

let appColor: Color = Color(red: 224 / 255, green: 84 / 255, blue: 9 / 255)
let feedColor: Color = Color(red: 247 / 255, green: 247 / 255, blue: 247 / 255)

#if DEBUG
let localFeedData: PaginatedResponse<Workout> = PaginatedResponse<Workout>(
    page: 1,
    count: 4,
    pages: 1,
    results: [
        Workout(
            id: 1,
            createdAt: "",
            updatedAt: "",
            name: "Leg day",
            date: "",
            exercises: [
                Exercise(
                    id: 1,
                    createdAt: "",
                    updatedAt: "",
                    name: "Curls",
                    type: "weighted",
                    raw: "1x3 curls",
                    weightedExercise: WeightedExercise(sets: 1, reps: 3),
                    distanceExercise: nil
                ),
                Exercise(
                    id: 1,
                    createdAt: "",
                    updatedAt: "",
                    name: "Benchpress",
                    type: "weighted",
                    raw: "4 sets of 3 of benchpress",
                    weightedExercise: WeightedExercise(sets: 4, reps: 3),
                    distanceExercise: nil
                )
            ]
        ),
        Workout(
            id: 1,
            createdAt: "",
            updatedAt: "",
            name: "Arm day",
            date: "",
            exercises: [
                Exercise(
                    id: 1,
                    createdAt: "",
                    updatedAt: "",
                    name: "Curls",
                    type: "weighted",
                    raw: "1 by 3 of curls",
                    weightedExercise: WeightedExercise(sets: 1, reps: 3),
                    distanceExercise: nil
                )
            ]
        )
    ]
)
#endif
