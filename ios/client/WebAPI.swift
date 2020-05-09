//
//  WebAPI.swift
//  client
//
//  Created by Nadir Muzaffar on 3/17/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation
import Alamofire
import JWTDecode

#if targetEnvironment(simulator)
let baseURL = "http://192.168.1.69:1234"
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
                    
                    let feedData = try! decoder.decode(PaginatedResponse<User>.self, from: data!)
                    completionHandler(feedData)
                case .failure(let error):
                    print("Failed to get users: ", error)
                    if let data = response.data {
                        print("Failed with error message from server", String(data: data, encoding: .utf8)!)
                    }
                }
            }
    }
}

class WorkoutAPI: ObservableObject {
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
    
    func getUserWorkouts(_ completionHandler: @escaping (PaginatedResponse<Workout>) -> Void) {
        let url = "\(baseURL)/api/workout"
        
        AF.request(url, method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .response(queue: DispatchQueue.main) { (response) in
                switch response.result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = decodeStrategy()
                    
                    let feedData = try! decoder.decode(PaginatedResponse<Workout>.self, from: data!)
                    completionHandler(feedData)
                case .failure(let error):
                    print("Failed to get workouts: ", error)
                    if let data = response.data {
                        print("Failed with error message from server", String(data: data, encoding: .utf8)!)
                    }
                }
            }
    }
    
    func getUserSubscriptionWorkouts(_ completionHandler: @escaping (PaginatedResponse<Workout>) -> Void) {
        let url = "\(baseURL)/api/workout/subscribedto"
        
        AF.request(url, method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .response(queue: DispatchQueue.main) { (response) in
                switch response.result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = decodeStrategy()
                    
                    let feedData = try! decoder.decode(PaginatedResponse<Workout>.self, from: data!)
                    completionHandler(feedData)
                case .failure(let error):
                    print("Failed to get workouts: ", error)
                    if let data = response.data {
                        print("Failed with error message from server", String(data: data, encoding: .utf8)!)
                    }
                }
            }
    }
    
    func createWorkout(workout: Workout, _ completionHandler: @escaping (Workout) -> Void) {
        AF.request("\(baseURL)/api/workout", method: .post, parameters: workout, encoder: JSONParameterEncoder(encoder: encoder), headers: headers)
            .validate(statusCode: 200..<300)
            .response(queue: DispatchQueue.main) { (response) in
                switch response.result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = decodeStrategy()
                    
                    let workout = try! decoder.decode(Workout.self, from: data!)
                    completionHandler(workout)
                case .failure(let error):
                    print("Failed to create workout", error)
                    if let data = response.data {
                        print("Failed with error message from server", String(data: data, encoding: .utf8)!)
                    }
                }
            }
    }
}

class MockWorkoutAPI: WorkoutAPI {
    let localFeedData: PaginatedResponse<Workout> = PaginatedResponse<Workout>(
        page: 1,
        pages: 1,
        size: -1,
        results: [
            Workout(
                id: 1,
                createdAt: "",
                updatedAt: "",
                name: "Monday morning workout",
                date: Date(),
                exercises: [
                    Exercise(
                        id: 1,
                        createdAt: "",
                        updatedAt: "",
                        name: "Curls",
                        type: "weighted",
                        raw: "1x3 curls",
                        data: ExerciseData(sets: 1, reps: 3, weight: 0, time: 0, distance: 0)
                    ),
                    Exercise(
                        id: 2,
                        createdAt: "",
                        updatedAt: "",
                        name: "Benchpress",
                        type: "weighted",
                        raw: "4 sets of 3 of benchpress",
                        data: ExerciseData(sets: 4, reps: 3, weight: 0, time: 0, distance: 0)
                    )
                ],
                location: Location(latitude: 37.34727983131215, longitude: -121.88308869874288)
            ),
            Workout(
                id: 2,
                createdAt: "",
                updatedAt: "",
                name: "Wednesday afternoon workout",
                date: Date(),
                exercises: [
                    Exercise(
                        id: 3,
                        createdAt: "",
                        updatedAt: "",
                        name: "Curls",
                        type: "weighted",
                        raw: "1 by 3 of curls",
                        data: ExerciseData(sets: 1, reps: 3, weight: 0, time: 0, distance: 0)
                    )
                ],
                location: Location(latitude: 37.34727983131215, longitude: -121.88308869874288)
            ),
            Workout(
                id: 3,
                createdAt: "",
                updatedAt: "",
                name: "Friday evening workout",
                date: Date(),
                exercises: [
                    Exercise(
                        id: 4,
                        createdAt: "",
                        updatedAt: "",
                        name: "Curls",
                        type: "weighted",
                        raw: "1 by 3 of curls",
                        data: ExerciseData(sets: 1, reps: 3, weight: 0, time: 0, distance: 0)
                    )
                ],
                location: Location(latitude: 37.34727983131215, longitude: -121.88308869874288)
            )
        ]
    )

    override func getUserSubscriptionWorkouts(_ completionHandler: @escaping (PaginatedResponse<Workout>) -> Void) {
        completionHandler(self.localFeedData)
    }
}

class ExerciseAPI: ObservableObject {
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
    
    func resolveExercise(exercise: Exercise, _ completionHandler: @escaping (Exercise) -> Void) -> DataRequest? {
        return AF.request("\(baseURL)/api/exercise/resolve", method: .post, parameters: exercise, encoder: JSONParameterEncoder(encoder: encoder), headers: headers)
            .validate(statusCode: 200..<300)
            .response(queue: DispatchQueue.main) { (response) in
                switch response.result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = decodeStrategy()
                    
                    let e = try! decoder.decode(Exercise.self, from: data!)
                    completionHandler(e)
                case .failure(let error):
                    print("Failed to resolve exercise: ", error)
                }
            }
    }
}

class MockExerciseAPI: ExerciseAPI {
    override func resolveExercise(exercise: Exercise, _ completionHandler: @escaping (Exercise) -> Void) -> DataRequest? {
        completionHandler(Exercise(
            id: 1,
            createdAt: "",
            updatedAt: "",
            name: "Curls",
            type: "weighted",
            raw: "1 by 3 of curls",
            data: ExerciseData(sets: 1, reps: 3, weight: 10, time: 0, distance: 0)
        ))
        
        return nil
    }
}

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

struct WeeklyMetric: Codable {
    let sets: Int
    let reps: Int
    let distance: Float
    let secondsElapsed: Int

    enum CodingKeys: String, CodingKey {
        case secondsElapsed = "seconds_elapsed"
        case sets, reps, distance
    }
}

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
    
    func getWeekly(_ completionHandler: @escaping (WeeklyMetric) -> Void) {
        let url = "\(baseURL)/api/metric/weekly"
        
        AF.request(url, method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .response(queue: DispatchQueue.main) { (response) in
                switch response.result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = decodeStrategy()
                    
                    let exerciseDictionary = try! decoder.decode(WeeklyMetric.self, from: data!)
                    completionHandler(exerciseDictionary)
                case .failure(let error):
                    print("Failed to get metric: ", error)
                    if let data = response.data {
                        print("Failed with error message from server", String(data: data, encoding: .utf8)!)
                    }
                }
        }
    }
}
