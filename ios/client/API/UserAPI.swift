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
import UIKit
import Promises
import Kingfisher

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
    
    func patchMeUser(user: User) -> Promise<User> {
        let url = "\(baseURL)/api/user/me"
        
        return Promise<User> { (fulfill, reject) in
            AF
                .request(url, method: .patch, parameters: user, encoder: JSONParameterEncoder(encoder: self.encoder), headers: self.headers)
                .validate(statusCode: 200..<300)
                .response(queue: DispatchQueue.main) { (response) in
                    switch response.result {
                    case .success(let data):
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = decodeStrategy()
                        
                        let result = try! decoder.decode(User.self, from: data!)
                        fulfill(result)
                    case .failure(let error):
                        print("Failed to update user: ", error)
                        if let data = response.data {
                            print("Failed with error message from server", String(data: data, encoding: .utf8)!)
                        }
                        reject(error)
                    }
                }
        }
    }
    
    func getImage(for userID: Int) -> Promise<UIImage> {
        let url = "\(baseURL)/api/user/\(userID)/image"
        
        let cache = ImageCache.default
        print("Cache timeout: ", cache.diskStorage.config.expiration)
        print("Cache timeout: ", cache.memoryStorage.config.expiration)
        
        return Promise<UIImage> { (fulfill, reject) in
            if cache.isCached(forKey: url) {
                cache.retrieveImage(forKey: url) { result in
                    switch result {
                    case .success(let value):
                        fulfill(value.image!)
                    case .failure(let error):
                        print("Failed to retreive image from cache!")
                        reject(error)
                    }
                }
            } else {
                _ = AF
                    .download(url, headers: self.headers)
                    .validate(statusCode: 200..<300)
                    .responseData(queue: DispatchQueue.main) { (response) in
                        switch response.result {
                        case .success(let data):
                            guard let image = UIImage(data: data) else {
                                reject("Failed to load image from data")
                                return
                            }
                            
                            cache.store(image, forKey: url)
                            
                            fulfill(image)
                        case .failure(let error):
                            print("Failed to download image: ", error)
                            reject(error)
                        }
                    }
            }
        }
    }
    
    func updateMeUserImage(_ image: UIImage) -> Promise<Void> {
        let url = "\(baseURL)/api/user/me/image"
        
        guard let data = image.jpegData(compressionQuality: 1.0) else {
            let promise = Promise<Void>.pending()
            promise.reject("Couldn't convert image to JPEG")
            print("Couldn't convert image to JPEG")
            return promise
        }
        
        return Promise<Void> { (fulfill, reject) in
            _ = AF
                .upload(multipartFormData: { (multipart :MultipartFormData) in
                    multipart.append(data, withName: "file", fileName: "file", mimeType: "image/jpeg")
                }, to: url, headers: self.headers)
                .validate(statusCode: 200..<300)
                .response(queue: DispatchQueue.main) { (response) in
                    switch response.result {
                    case .success(_):
                        let key = "\(baseURL)/api/user/\(self.userState.userInfo.id!)/image"
                        ImageCache.default.store(image, forKey: key)
                        
                        fulfill(()) // weird syntax to fulfill Promise<Void>
                    case .failure(let error):
                        print("Failed to upload image: ", error)
                        if let data = response.data {
                            print("Failed with error message from server: ", String(data: data, encoding: .utf8)!)
                        }
                    }
                }
        }
    }
}
