//
//  LocationAPI.swift
//  client
//
//  Created by Nadir Muzaffar on 6/11/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation
import Alamofire
import JWTDecode
import Promises

class LocationAPI: ObservableObject {
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
    
    func createLocation(_ location: Location) -> Promise<Location> {
        let url = "\(baseURL)/api/exercise/\(location.exerciseID!)/location"
        
        return Promise<Location> { (fulfill, reject) in
            AF
                .request(url, method: .post, parameters: location, encoder: JSONParameterEncoder(encoder: self.encoder), headers: self.headers)
                .validate()
                .response { (response) in
                    switch response.result {
                    case .success(let data):
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = decodeStrategy()
                        
                        let result = try! decoder.decode(Location.self, from: data!)
                        fulfill(result)
                    case .failure(let error):
                        print("Failed to create location", error)
                        if let data = response.data {
                            print("Failed with error message from server", String(data: data, encoding: .utf8)!)
                        }
                        reject(error)
                    }
                }
        }
    }
    
    func createLocations(exerciseID: Int, _ locations: [Location]) -> Promise<PaginatedResponse<Location>> {
        let url = "\(baseURL)/api/exercise/\(exerciseID)/locations"
        
        return Promise<PaginatedResponse<Location>> { (fulfill, reject) in
            AF
                .request(url, method: .post, parameters: locations, encoder: JSONParameterEncoder(encoder: self.encoder), headers: self.headers)
                .validate()
                .response { (response) in
                    switch response.result {
                    case .success(let data):
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = decodeStrategy()
                        
                        let result = try! decoder.decode(PaginatedResponse<Location>.self, from: data!)
                        fulfill(result)
                    case .failure(let error):
                        print("Failed to create locations", error)
                        if let data = response.data {
                            print("Failed with error message from server", String(data: data, encoding: .utf8)!)
                        }
                        reject(error)
                    }
                }
        }
    }
}
