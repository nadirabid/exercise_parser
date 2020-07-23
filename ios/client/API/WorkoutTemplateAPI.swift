//
//  WorkoutTemplateAPI.swift
//  client
//
//  Created by Nadir Muzaffar on 7/16/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation

import Foundation
import Alamofire
import JWTDecode
import Promises

class WorkoutTemplateAPI: ObservableObject {
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
    
    func all(page: Int = 0, pageSize: Int = 20) -> Promise<PaginatedResponse<WorkoutTemplate>> {
        let url = "\(baseURL)/api/workout/template"
        let params: Parameters = [
            "page": page.description,
            "size": pageSize.description
        ]
        
        return Promise<PaginatedResponse<WorkoutTemplate>> { (fulfill, reject) in
            AF.request(url, method: .get, parameters: params, headers: self.headers)
                .validate(statusCode: 200..<300)
                .response(queue: DispatchQueue.main) { (response) in
                    switch response.result {
                    case .success(let data):
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = decodeStrategy()
                        
                        let result = try! decoder.decode(PaginatedResponse<WorkoutTemplate>.self, from: data!)
                        fulfill(result)
                    case .failure(let error):
                        print("Failed to get workout templates: ", error)
                        if let data = response.data {
                            print("Failed with error message from server", String(data: data, encoding: .utf8)!)
                        }
                    }
            }
        }
    }
    
    func create(workoutTemplate: WorkoutTemplate) -> Promise<WorkoutTemplate> {
        let url = "\(baseURL)/api/workout/template"
        
        return Promise<WorkoutTemplate> { (fulfill, reject) in
            AF.request(url, method: .post, parameters: workoutTemplate, encoder: JSONParameterEncoder(encoder: self.encoder), headers: self.headers)
                .validate(statusCode: 200..<300)
                .response(queue: DispatchQueue.main) { (response) in
                    switch response.result {
                    case .success(let data):
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = decodeStrategy()
                        
                        let result = try! decoder.decode(WorkoutTemplate.self, from: data!)
                        fulfill(result)
                    case .failure(let error):
                        print("Failed to create workout template", error)
                        if let data = response.data {
                            print("Failed with error message from server", String(data: data, encoding: .utf8)!)
                        }
                    }
            }
        }
    }
    
    func delete(workoutTemplate: WorkoutTemplate) -> Promise<Void> {
        let url = "\(baseURL)/api/workout/template/\(workoutTemplate.id!)"
        
        return Promise<Void> { (fulfill, reject) in
            AF
                .request(url, method: .delete, headers: self.headers)
                .validate(statusCode: 200..<300)
                .response(queue: DispatchQueue.main) { (response) in
                    switch response.result {
                    case .success:
                        fulfill(())
                    case .failure(let error):
                        print("Failed to delete workout template", error)
                        if let data = response.data {
                            print("Failed with error message from server", String(data: data, encoding: .utf8)!)
                        }
                        reject(error)
                    }
            }
        }
    }
}
