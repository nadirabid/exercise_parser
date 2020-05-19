//
//  AuthAPI.swift
//  client
//
//  Created by Nadir Muzaffar on 5/19/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation
import Alamofire
import JWTDecode

class AuthAPI: ObservableObject {
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
                    decoder.dateDecodingStrategy = decodeStrategy()
                    
                    let r = try! decoder.decode(UserRegistrationResponse.self, from: data!)
                    let jwt = try! decode(jwt: r.token)
                    
                    completionHandler(jwt, r.user)
                case .failure(let error):
                    print(error)
                }
            }
    }
}
