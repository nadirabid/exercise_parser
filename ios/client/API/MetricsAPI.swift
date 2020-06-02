//
//  MetricsAPI.swift
//  client
//
//  Created by Nadir Muzaffar on 5/19/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation
import Alamofire
import JWTDecode

class MetricAPI: ObservableObject {
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

    func getForPast(days: Int, _ completionHandler: @escaping (Metric) -> Void) {
        let url = "\(baseURL)/api/metric"
        let params: Parameters = [
            "pastDays": days.description
        ]
        
        AF.request(url, method: .get, parameters: params, headers: headers)
            .validate(statusCode: 200..<300)
            .response(queue: DispatchQueue.main) { (response) in
                switch response.result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = decodeStrategy()
                    
                    let result = try! decoder.decode(Metric.self, from: data!)
                    completionHandler(result)
                case .failure(let error):
                    print("Failed to get metric: ", error)
                    if let data = response.data {
                        print("Failed with error message from server", String(data: data, encoding: .utf8)!)
                    }
                }
        }
    }
}

