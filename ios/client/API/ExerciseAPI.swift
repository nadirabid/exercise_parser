//
//  ExerciseAPI.swift
//  client
//
//  Created by Nadir Muzaffar on 5/19/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation
import Alamofire
import JWTDecode

class ExerciseAPI: ObservableObject {
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
    
    func resolveExercise(exercise: Exercise, _ completionHandler: @escaping (Exercise) -> Void) -> DataRequest? {
        return AF.request("\(baseURL)/api/exercise/resolve", method: .post, parameters: exercise, encoder: JSONParameterEncoder(encoder: encoder), headers: headers)
            .validate(statusCode: 200..<300)
            .response(queue: DispatchQueue.main) { (response) in
                switch response.result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = decodeStrategy()
                    
                    let e = try! decoder.decode(Exercise.self, from: data!)
                    completionHandler(e)
                case .failure(let error):
                    print("Failed to resolve exercise: ", error)
                }
            }
    }
}

class MockExerciseAPI: ExerciseAPI {
    override func resolveExercise(exercise: Exercise, _ completionHandler: @escaping (Exercise) -> Void) -> DataRequest? {
        completionHandler(Exercise(
            id: 1,
            createdAt: "",
            updatedAt: "",
            name: "Curls",
            type: "weighted",
            raw: "1 by 3 of curls",
            data: ExerciseData(sets: 1, reps: 3, weight: 10, time: 0, distance: 0)
        ))
        
        return nil
    }
}
