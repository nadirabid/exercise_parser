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

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let userState = UserState()
        
        // MARK: configure cache
        
        
        ImageCache.default.diskStorage.config.expiration = .seconds(5*60*60)
        ImageCache.default.memoryStorage.config.expiration = .seconds(5*60*60)

        // MARK: setup scene
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            let rootView = MainView()
                .environmentObject(userState)
                .environmentObject(WorkoutCreateState())
                .environmentObject(RouteState())
                .environmentObject(AuthAPI())
                .environmentObject(UserAPI(userState: userState))
                .environmentObject(WorkoutAPI(userState: userState))
                .environmentObject(ExerciseAPI(userState: userState))
                .environmentObject(ExerciseDictionaryAPI(userState: userState))
                .environmentObject(MetricAPI(userState: userState))
                .environmentObject(LocationAPI(userState: userState))
                .environmentObject(UserFeedState())
            
            window.rootViewController = UIHostingController(rootView: rootView)
            window.rootViewController?.overrideUserInterfaceStyle = .light
            
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
