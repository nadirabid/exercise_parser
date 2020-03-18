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
    
    func userRegistrationAndLogin(
        identityToken: String,
        data: UserRegistrationData,
        _ completionHandler: @escaping (JWT) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Authorization": "Bearer \(identityToken)"
        ]
        
        let url = "\(baseURL)/user/register"
        
        struct UserRegistrationResponse: Codable {
            let token: String
        }
        
        AF
            .request(url, method: .post, parameters: data, encoder: JSONParameterEncoder.default, headers: headers)
            .validate(statusCode: 200..<300)
            .response(queue: DispatchQueue.main) { (response) in
                switch response.result {
                case .success(let data):
                    let t = try! JSONDecoder().decode(UserRegistrationResponse.self, from: data!)
                    let jwt = try! decode(jwt: t.token)
                    
                    completionHandler(jwt)
                case .failure(let error):
                    print(error)
                }
            }
    }
}

class WorkoutAPI: ObservableObject {
    private var userState: UserState

    init(userState: UserState) {
        self.userState = userState
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
                    let feedData = try! JSONDecoder().decode(PaginatedResponse<Workout>.self, from: data!)
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
        
        AF.request("\(baseURL)/workout", method: .post, parameters: workout, encoder: JSONParameterEncoder.default, headers: headers)
            .validate(statusCode: 200..<300)
            .response(queue: DispatchQueue.main) { (response) in
                switch response.result {
                case .success(let data):
                    let workout = try! JSONDecoder().decode(Workout.self, from: data!)
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

class ExerciseAPI: ObservableObject {
    private var userState: UserState

    init(userState: UserState) {
        self.userState = userState
    }
    
    func resolveExercise(exercise: Exercise, _ completionHandler: @escaping (Exercise) -> Void) {
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Authorization": "Bearer \(userState.jwt!.string)"
        ]
        
        AF.request("\(baseURL)/exercise/resolve", method: .post, parameters: exercise, encoder: JSONParameterEncoder.default, headers: headers)
            .validate(statusCode: 200..<300)
            .response(queue: DispatchQueue.main) { (response) in
                switch response.result {
                case .success(let data):
                    let e = try! JSONDecoder().decode(Exercise.self, from: data!)
                    completionHandler(e)
                case .failure(let error):
                    print("Failed to resolve exercise: ", error)
                }
            }
    }
}
