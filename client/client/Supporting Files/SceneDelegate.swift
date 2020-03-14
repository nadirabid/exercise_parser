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

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let userState = UserState()
        
//        if let userID = UserDefaults.standard.object(forKey: "userId") as? String {
//            let appleIDProvider = ASAuthorizationAppleIDProvider()
//            appleIDProvider.getCredentialState(forUserID: userID) { (state, error) in
//                DispatchQueue.main.async {
//                    switch state
//                    {
//                    case .authorized: // valid user id
//                        userState.authorization = 1
//                        break
//                    case .revoked: // user revoked authorization
//                        userState.authorization = -1
//                        break
//                    case .notFound: //not found
//                        userState.authorization = 0
//                        break
//                    default:
//                        break
//                    }
//                }
//            }
//        }
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            let rootView = MainView()
                .environmentObject(WorkoutEditorState())
                .environmentObject(RouteState())
                .environmentObject(userState)
            
            window.rootViewController = UIHostingController(rootView: rootView)
            
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}

