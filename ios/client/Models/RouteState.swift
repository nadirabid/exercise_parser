//
//  RouteState.swift
//  client
//
//  Created by Nadir Muzaffar on 5/19/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation
import SwiftUI

class RouteState: ObservableObject {
    @Published var current: Route
    @Published var showHelp: Bool
    @Published var editUserProfile: Bool
    
    init(current: Route = .userFeed) {
        self.current = current
        self.showHelp = false
        self.editUserProfile = true
    }
    
    enum Route {
        case userFeed
        case userMetrics
        
        case editor
        
        case subscriptionFeed
    }
}
