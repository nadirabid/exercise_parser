//
//  User.swift
//  client
//
//  Created by Nadir Muzaffar on 3/15/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation
import JWTDecode

struct User: Codable, Hashable {
    let id: Int?
    let externalUserId: String?
    let email: String?
    let givenName: String?
    let familyName: String?
    let imageExists: Bool?
    let birthdate: Date?
    let weight: Float?
    let height: Float?
    let isMale: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    private enum CodingKeys: String, CodingKey {
        case externalUserId = "external_user_id"
        case email = "email"
        case givenName = "given_name"
        case familyName = "family_name"
        case imageExists = "image_exists"
        case isMale = "is_male"
        case id, birthdate, weight, height
    }
    
    func getUserName() -> String {
        if givenName != nil && familyName != nil {
            return "\(givenName!) \(familyName!)"
        } else if givenName != nil {
            return "\(givenName!)"
        } else {
            return ""
        }
    }
}

class UserState: ObservableObject {
    // 1 = Authorized, -1 = Revoked
    @Published var authorization: Int = 0
    @Published var jwt: JWT? = nil
    @Published var userInfo: User = User(id: nil, externalUserId: nil, email: nil, givenName: nil, familyName: nil, imageExists: false, birthdate: nil, weight: nil, height: nil, isMale: true)
}
