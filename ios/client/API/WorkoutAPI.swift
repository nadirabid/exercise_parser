//
//  WorkoutAPI.swift
//  client
//
//  Created by Nadir Muzaffar on 5/19/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation
import Alamofire
import JWTDecode
import Promises

class WorkoutAPI: ObservableObject {
    private var userState: UserState
    private let encoder = JSONEncoder()

    init(userState: UserState) {
        self.userState = userState
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    var headers: HTTPHeaders {
        return HTTPHeaders([
            "Accept": "application/json",
            "Authorization": "Bearer \(userState.jwt!.string)"
        ])
    }
    
    func getUserWorkouts(page: Int = 0, pageSize: Int = 20, _ completionHandler: @escaping (PaginatedResponse<Workout>) -> Void) -> DataRequest? {
        let url = "\(baseURL)/api/workout"
        let params: Parameters = [
            "page": page.description,
            "size": pageSize.description
        ]
        
        return AF.request(url, method: .get, parameters: params, headers: headers)
            .validate(statusCode: 200..<300)
            .response(queue: DispatchQueue.main) { (response) in
                switch response.result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = decodeStrategy()
                    
                    let result = try! decoder.decode(PaginatedResponse<Workout>.self, from: data!)
                    completionHandler(result)
                case .failure(let error):
                    print("Failed to get workouts: ", error)
                    if let data = response.data {
                        print("Failed with error message from server", String(data: data, encoding: .utf8)!)
                    }
                }
            }
    }
    
    func getUserSubscriptionWorkouts(page: Int = 0, pageSize: Int = 20, _ completionHandler: @escaping (PaginatedResponse<Workout>) -> Void) -> DataRequest? {
        let url = "\(baseURL)/api/workout/subscribedto"
        let params: Parameters = [
            "page": page.description,
            "size": pageSize.description
        ]
        
        return AF.request(url, method: .get, parameters: params, headers: headers)
            .validate(statusCode: 200..<300)
            .response(queue: DispatchQueue.main) { (response) in
                switch response.result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = decodeStrategy()
                    
                    let result = try! decoder.decode(PaginatedResponse<Workout>.self, from: data!)
                    completionHandler(result)
                case .failure(let error):
                    print("Failed to get workouts: ", error)
                    if let data = response.data {
                        print("Failed with error message from server", String(data: data, encoding: .utf8)!)
                    }
                }
            }
    }
    
    func createWorkout(workout: Workout, _ completionHandler: @escaping (Workout) -> Void) {
        AF.request("\(baseURL)/api/workout", method: .post, parameters: workout, encoder: JSONParameterEncoder(encoder: encoder), headers: headers)
            .validate(statusCode: 200..<300)
            .response(queue: DispatchQueue.main) { (response) in
                switch response.result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = decodeStrategy()
                    
                    let result = try! decoder.decode(Workout.self, from: data!)
                    completionHandler(result)
                case .failure(let error):
                    print("Failed to create workout", error)
                    if let data = response.data {
                        print("Failed with error message from server", String(data: data, encoding: .utf8)!)
                    }
                }
            }
    }
    
    func updateWorkout(workout: Workout) -> Promise<Workout> {
        let url = "\(baseURL)/api/workout/\(workout.id!)"
        
        return Promise<Workout> { (fulfill, reject) in
            AF
                .request(url, method: .put, parameters: workout, encoder: JSONParameterEncoder(encoder: self.encoder), headers: self.headers)
                .validate(statusCode: 200..<300)
                .response(queue: DispatchQueue.main) { (response) in
                    switch response.result {
                    case .success(let data):
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = decodeStrategy()
                        
                        let result = try! decoder.decode(Workout.self, from: data!)
                        fulfill(result)
                    case .failure(let error):
                        print("Failed to update workout", error)
                        if let data = response.data {
                            print("Failed with error message from server", String(data: data, encoding: .utf8)!)
                        }
                        reject(error)
                    }
                }
        }
    }
    
    func deleteWorkout(workout: Workout) -> Promise<Void> {
        let url = "\(baseURL)/api/workout/\(workout.id!)"
        
        return Promise<Void> { (fulfill, reject) in
            AF
                .request(url, method: .delete, headers: self.headers)
                .validate(statusCode: 200..<300)
                .response(queue: DispatchQueue.main) { (response) in
                    switch response.result {
                    case .success:
                        fulfill(())
                    case .failure(let error):
                        print("Failed to delete workout", error)
                        if let data = response.data {
                            print("Failed with error message from server", String(data: data, encoding: .utf8)!)
                        }
                        reject(error)
                    }
                }
        }
    }
}

class MockWorkoutAPI: WorkoutAPI {
    let localFeedData: PaginatedResponse<Workout> = PaginatedResponse<Workout>(
        page: 1,
        pages: 1,
        size: -1,
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
                        data: ExerciseData(sets: 1, reps: 3, weight: 0, time: 0, distance: 0)
                    ),
                    Exercise(
                        id: 2,
                        createdAt: "",
                        updatedAt: "",
                        name: "Benchpress",
                        type: "weighted",
                        raw: "4 sets of 3 of benchpress",
                        data: ExerciseData(sets: 4, reps: 3, weight: 0, time: 0, distance: 0)
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
                        data: ExerciseData(sets: 1, reps: 3, weight: 0, time: 0, distance: 0)
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
                        data: ExerciseData(sets: 1, reps: 3, weight: 0, time: 0, distance: 0)
                    )
                ],
                location: Location(latitude: 37.34727983131215, longitude: -121.88308869874288)
            )
        ]
    )

    override func getUserSubscriptionWorkouts(page: Int = 0, pageSize: Int = 20, _ completionHandler: @escaping (PaginatedResponse<Workout>) -> Void) -> DataRequest? {
        completionHandler(self.localFeedData)
        return nil
    }
}

