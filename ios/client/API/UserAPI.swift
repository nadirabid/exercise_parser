//
//  UserAPI.swift
//  client
//
//  Created by Nadir Muzaffar on 5/19/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation
import Alamofire
import JWTDecode

class UserAPI: ObservableObject {
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
    
    func getUsersByIDs(users: Set<Int>, _ completionHandler: @escaping (PaginatedResponse<User>) -> Void) {
        let url = "\(baseURL)/api/user"
        let params: Parameters = [
            "users": users.map { String($0) }.joined(separator: ",")
        ]
        
        AF.request(url, method: .get, parameters: params, headers: headers)
            .validate(statusCode: 200..<300)
            .response(queue: DispatchQueue.main) { (response) in
                switch response.result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = decodeStrategy()
                    
                    let result = try! decoder.decode(PaginatedResponse<User>.self, from: data!)
                    completionHandler(result)
                case .failure(let error):
                    print("Failed to get users: ", error)
                    if let data = response.data {
                        print("Failed with error message from server", String(data: data, encoding: .utf8)!)
                    }
                }
            }
    }
    
    func patchMeUser(user: User, _ completionHandler: @escaping (User) -> Void) {
        let url = "\(baseURL)/api/user/me"
        
        AF.request(url, method: .patch, parameters: user, encoder: JSONParameterEncoder(encoder: encoder), headers: headers)
            .validate(statusCode: 200..<300)
            .response(queue: DispatchQueue.main) { (response) in
                switch response.result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = decodeStrategy()
                    
                    let result = try! decoder.decode(User.self, from: data!)
                    completionHandler(result)
                case .failure(let error):
                    print("Failed to update user: ", error)
                    if let data = response.data {
                        print("Failed with error message from server", String(data: data, encoding: .utf8)!)
                    }
                }
            }
    }
}
