//
//  WebAPI.swift
//  client
//
//  Created by Nadir Muzaffar on 3/17/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation

#if targetEnvironment(simulator)
//let baseURL = "http://192.168.1.69:1234"
let baseURL = "http://192.168.1.129:1234"
#else
let baseURL = "https://api.rydenapp.com"
#endif

enum DateError: String, Error {
    case invalidDate
}

func decodeStrategy() -> JSONDecoder.DateDecodingStrategy {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)

    
    return .custom({ (decoder) -> Date in
        let container = try decoder.singleValueContainer()
        let dateStr = try container.decode(String.self)

        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        if let date = formatter.date(from: dateStr) {
            return date
        }
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        if let date = formatter.date(from: dateStr) {
            return date
        }
        
        throw DateError.invalidDate
    })
}
