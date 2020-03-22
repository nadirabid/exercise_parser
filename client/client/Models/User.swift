//
//  User.swift
//  client
//
//  Created by Nadir Muzaffar on 3/15/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation
import JWTDecode

struct User: Codable {
    let id: Int?
    let externalUserId: String
    let email: String?
    let givenName: String?
    let familyName: String?
    
    private enum CodingKeys: String, CodingKey {
        case externalUserId = "external_user_id"
        case email = "email"
        case givenName = "given_name"
        case familyName = "family_name"
        case id
    }
}

class UserState: ObservableObject {
    // 1 = Authorized, -1 = Revoked
    @Published var authorization: Int = 0
    @Published var jwt: JWT? = nil
    @Published var userInfo: User? = nil
}
