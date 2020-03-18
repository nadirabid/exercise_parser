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

func checkIfJWTIsValid(_ token: String) -> Bool {
    if let jwt = try? decode(jwt: token) {
        return jwt.expired
    }
    
    return false
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
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
                    
                    if userState.authorization == 1 {
                        if let token = UserDefaults.standard.object(forKey: "token") as? String {
                            if let jwt = try? decode(jwt: token) {
                                if !jwt.expired {
                                    userState.jwt = jwt
                                    return
                                }
                            }
                        }
                        
                        // token is invalid so show sign in page
                        userState.authorization = 0
                    }
                }
            }
        }
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            let rootView = MainView()
                .environmentObject(WorkoutEditorState())
                .environmentObject(RouteState())
                .environmentObject(userState)
                .environmentObject(UserAPI())
                .environmentObject(WorkoutAPI(userState: userState))
                .environmentObject(ExerciseAPI(userState: userState))
            
            window.rootViewController = UIHostingController(rootView: rootView)
            window.rootViewController?.overrideUserInterfaceStyle = .light
            
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
