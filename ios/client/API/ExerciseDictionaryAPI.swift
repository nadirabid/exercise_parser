//
//  ExerciseDictionaryAPI.swift
//  client
//
//  Created by Nadir Muzaffar on 5/19/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation
import Alamofire
import JWTDecode
import Promises

class ExerciseDictionaryAPI: ObservableObject {
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
    
    func getDictionary(id: Int, _ completionHandler: @escaping (ExerciseDictionary) -> Void) {
        let url = "\(baseURL)/api/exercise/dictionary/\(id)"
        
        AF.request(url, method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .response(queue: DispatchQueue.main) { (response) in
                switch response.result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = decodeStrategy()
                    
                    let exerciseDictionary = try! decoder.decode(ExerciseDictionary.self, from: data!)
                    completionHandler(exerciseDictionary)
                case .failure(let error):
                    print("Failed to get exercise dictionary: ", error)
                    if let data = response.data {
                        print("Failed with error message from server", String(data: data, encoding: .utf8)!)
                    }
                }
            }
    }
    
    func getDictionarySearchLite(query: String) -> Promise<PaginatedResponse<Int>> {
        let url = "\(baseURL)/api/dictionary/search/lite"
        
        let parameters = ["query": query]
        
        return Promise<PaginatedResponse<Int>> { (fulfill, reject) in
            AF
                .request(url, method: .get, parameters: parameters, headers: self.headers)
                .validate()
                .response { (response) in
                    switch response.result {
                    case .success(let data):
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = decodeStrategy()
                        
                        let result = try! decoder.decode(PaginatedResponse<Int>.self, from: data!)
                        fulfill(result)
                    case .failure(let error):
                        print("Failed to get exercise dictionaries IDs list: ", error)
                        if let data = response.data {
                            print("Failed with error message from server", String(data: data, encoding: .utf8)!)
                        }
                    }
                }
        }
    }
    
    func getDictionaryList() -> Promise<PaginatedResponse<ExerciseDictionary>> {
        let url = "\(baseURL)/api/dictionary?page=0&size=0"
        
        return Promise<PaginatedResponse<ExerciseDictionary>> { (fulfill, reject) in
            AF
                .request(url, method: .get, headers: self.headers)
                .validate()
                .response { (response) in
                    switch response.result {
                    case .success(let data):
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = decodeStrategy()
                        
                        let result = try! decoder.decode(PaginatedResponse<ExerciseDictionary>.self, from: data!)
                        fulfill(result)
                    case .failure(let error):
                        print("Failed to get exercise dictionaries list: ", error)
                        if let data = response.data {
                            print("Failed with error message from server", String(data: data, encoding: .utf8)!)
                        }
                    }
                }
        }
    }
    
    func getWorkoutDictionaries(id: Int, _ completionHandler: @escaping (PaginatedResponse<ExerciseDictionary>) -> Void) {
        let url = "\(baseURL)/api/workout/\(id)/dictionary/"
        
        AF.request(url, method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .response(queue: DispatchQueue.main) { (response) in
                switch response.result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = decodeStrategy()
                    
                    let result = try! decoder.decode(PaginatedResponse<ExerciseDictionary>.self, from: data!)
                    completionHandler(result)
                case .failure(let error):
                    print("Failed to get exercise dictionary: ", error)
                    if let data = response.data {
                        print("Failed with error message from server", String(data: data, encoding: .utf8)!)
                    }
                }
            }
    }
}
