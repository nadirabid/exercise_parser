//
//  WebAPI.swift
//  client
//
//  Created by Nadir Muzaffar on 3/17/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation
import Alamofire
import JWTDecode

let baseURL = "http://192.168.1.69:1234"

class UserAPI: ObservableObject {
    struct UserRegistrationResponse: Codable {
        let token: String
    }
    
    private let encoder = JSONEncoder()
    
    init() {
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    func userRegistrationAndLogin(
        identityToken: String,
        data: User,
        _ completionHandler: @escaping (JWT, User) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Authorization": "Bearer \(identityToken)"
        ]
        
        let url = "\(baseURL)/user/register"
        
        struct UserRegistrationResponse: Codable {
            let token: String
            let user: User
        }
        
        AF
            .request(url, method: .post, parameters: data, encoder: JSONParameterEncoder(encoder: encoder), headers: headers)
            .validate(statusCode: 200..<300)
            .response(queue: DispatchQueue.main) { (response) in
                switch response.result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    let r = try! decoder.decode(UserRegistrationResponse.self, from: data!)
                    let jwt = try! decode(jwt: r.token)
                    
                    completionHandler(jwt, r.user)
                case .failure(let error):
                    print(error)
                }
            }
    }
}

class WorkoutAPI: ObservableObject {
    private var userState: UserState
    private let encoder = JSONEncoder()

    init(userState: UserState) {
        self.userState = userState
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    func getUserFeed(_ completionHandler: @escaping (PaginatedResponse<Workout>) -> Void) {
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Authorization": "Bearer \(userState.jwt!.string)"
        ]
        
        let url = "\(baseURL)/workout"
        
        AF.request(url, method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .response(queue: DispatchQueue.main) { (response) in
                switch response.result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    let feedData = try! decoder.decode(PaginatedResponse<Workout>.self, from: data!)
                    completionHandler(feedData)
                case .failure(let error):
                    print("Failed to get workouts: ", error)
                    if let data = response.data {
                        print("Failed with error message from server", String(data: data, encoding: .utf8)!)
                    }
                }
            }
    }
    
    func createWorkout(workout: Workout, _ completionHandler: @escaping (Workout) -> Void) {
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Authorization": "Bearer \(userState.jwt!.string)"
        ]
        
        AF.request("\(baseURL)/workout", method: .post, parameters: workout, encoder: JSONParameterEncoder(encoder: encoder), headers: headers)
            .validate(statusCode: 200..<300)
            .response(queue: DispatchQueue.main) { (response) in
                switch response.result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    let workout = try! decoder.decode(Workout.self, from: data!)
                    completionHandler(workout)
                case .failure(let error):
                    print("Failed to create workout", error)
                    if let data = response.data {
                        print("Failed with error message from server", String(data: data, encoding: .utf8)!)
                    }
                }
            }
    }
}

class MockWorkoutAPI: WorkoutAPI {
    let localFeedData: PaginatedResponse<Workout> = PaginatedResponse<Workout>(
        page: 1,
        count: 4,
        pages: 1,
        results: [
            Workout(
                id: 1,
                createdAt: "",
                updatedAt: "",
                name: "Monday morning workout",
                date: Date(),
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
                        id: 2,
                        createdAt: "",
                        updatedAt: "",
                        name: "Benchpress",
                        type: "weighted",
                        raw: "4 sets of 3 of benchpress",
                        weightedExercise: WeightedExercise(sets: 4, reps: 3),
                        distanceExercise: nil
                    )
                ],
                location: Location(latitude: 37.34727983131215, longitude: -121.88308869874288)
            ),
            Workout(
                id: 2,
                createdAt: "",
                updatedAt: "",
                name: "Wednesday afternoon workout",
                date: Date(),
                exercises: [
                    Exercise(
                        id: 3,
                        createdAt: "",
                        updatedAt: "",
                        name: "Curls",
                        type: "weighted",
                        raw: "1 by 3 of curls",
                        weightedExercise: WeightedExercise(sets: 1, reps: 3),
                        distanceExercise: nil
                    )
                ],
                location: Location(latitude: 37.34727983131215, longitude: -121.88308869874288)
            ),
            Workout(
                id: 3,
                createdAt: "",
                updatedAt: "",
                name: "Friday evening workout",
                date: Date(),
                exercises: [
                    Exercise(
                        id: 4,
                        createdAt: "",
                        updatedAt: "",
                        name: "Curls",
                        type: "weighted",
                        raw: "1 by 3 of curls",
                        weightedExercise: WeightedExercise(sets: 1, reps: 3),
                        distanceExercise: nil
                    )
                ],
                location: Location(latitude: 37.34727983131215, longitude: -121.88308869874288)
            )
        ]
    )

    override func getUserFeed(_ completionHandler: @escaping (PaginatedResponse<Workout>) -> Void) {
        completionHandler(self.localFeedData)
    }
}

class ExerciseAPI: ObservableObject {
    private var userState: UserState
    private let encoder = JSONEncoder()

    init(userState: UserState) {
        self.userState = userState
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    func resolveExercise(exercise: Exercise, _ completionHandler: @escaping (Exercise) -> Void) {
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Authorization": "Bearer \(userState.jwt!.string)"
        ]
        
        AF.request("\(baseURL)/exercise/resolve", method: .post, parameters: exercise, encoder: JSONParameterEncoder(encoder: encoder), headers: headers)
            .validate(statusCode: 200..<300)
            .response(queue: DispatchQueue.main) { (response) in
                switch response.result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    let e = try! decoder.decode(Exercise.self, from: data!)
                    completionHandler(e)
                case .failure(let error):
                    print("Failed to resolve exercise: ", error)
                }
            }
    }
}

class MockExerciseAPI: ExerciseAPI {
    override func resolveExercise(exercise: Exercise, _ completionHandler: @escaping (Exercise) -> Void) {
        completionHandler(Exercise(
            id: 1,
            createdAt: "",
            updatedAt: "",
            name: "Curls",
            type: "weighted",
            raw: "1 by 3 of curls",
            weightedExercise: WeightedExercise(sets: 1, reps: 3),
            distanceExercise: nil
        ))
    }
}
