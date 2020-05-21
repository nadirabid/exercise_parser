//
//  SceneDelegate.swift
//  client
//
//  Created by Nadir Muzaffar on 6/15/19.
//  Copyright © 2019 Nadir Muzaffar. All rights reserved.
//

import UIKit
import SwiftUI
import AuthenticationServices
import JWTDecode
import Kingfisher

func checkIfJWTIsValid(_ token: String) -> Bool {
    if let jwt = try? decode(jwt: token) {
        return jwt.expired
    }
    
    return false
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // MARK: confirm authentication state
        
        let userState = UserState()
        
        // this check of "is user authenticated" needs to be abstracted
        if let userID = UserDefaults.standard.object(forKey: "userId") as? String {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: userID) { (state, error) in
                DispatchQueue.main.async {
                    switch state
                    {
                    case .authorized: // valid user id
                        userState.authorization = 1
                        break
                    case .revoked: // user revoked authorization
                        userState.authorization = -1
                        break
                    case .notFound: //not found
                        userState.authorization = 0
                        break
                    default:
                        break
                    }
                    
                    if let userJSON = UserDefaults.standard.object(forKey: "userInfo") as? String {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        
                        if let user = try? decoder.decode(User.self, from: userJSON.data(using: .utf8) ?? Data()) {
                            userState.userInfo = user
                        } else {
                            userState.authorization = 0
                        }
                    } else {
                        // userInfo doesn't exist - this won't really happen because
                        // if we're authed then we also stored the user info as part of sign in
                        userState.authorization = 0
                    }
                    
                    if userState.authorization == 1 {
                        if let token = UserDefaults.standard.object(forKey: "token") as? String {
                            if let jwt = try? decode(jwt: token), !jwt.expired {
                                userState.jwt = jwt
                                return
                            }
                        }
                        
                        // token is invalid so show sign in page
                        userState.authorization = 0
                    }
                }
            }
        }
        
        // MARK: configure cache
        
        ImageCache.default.diskStorage.config.expiration = .seconds(30*60)
        ImageCache.default.memoryStorage.config.expiration = .seconds(30*60)

        // MARK: setup scene
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            let rootView = MainView()
                .environmentObject(userState)
                .environmentObject(EditableWorkoutState())
                .environmentObject(RouteState())
                .environmentObject(AuthAPI())
                .environmentObject(UserAPI(userState: userState))
                .environmentObject(WorkoutAPI(userState: userState))
                .environmentObject(ExerciseAPI(userState: userState))
                .environmentObject(ExerciseDictionaryAPI(userState: userState))
                .environmentObject(MetricAPI(userState: userState))
            
            window.rootViewController = UIHostingController(rootView: rootView)
            window.rootViewController?.overrideUserInterfaceStyle = .light
            
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
