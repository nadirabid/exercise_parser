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
    @Published private var routeStack: [Route]
    @Published var showHelp: Bool
    @Published var editWorkout: Workout?
    
    init(current: Route = .userFeed) {
        self.routeStack = []
        self.showHelp = false
        self.editWorkout = nil
        
        self.push(route: current)
    }
    
    func clearAndSet(route: Route) {
        if !routeStack.isEmpty {
            routeStack.removeAll()
        }
        
        push(route: route)
    }
    
    func replaceCurrent(with route: Route) {
        if !routeStack.isEmpty {
            _ = routeStack.popLast()
        }
        
        push(route: route)
    }
    
    func push(route: Route) {
        routeStack.append(route)
    }
    
    func pop() {
        if routeStack.count <= 1 {
            return
        }
        
        _ = routeStack.popLast()
    }
    
    func peek() -> Route {
        return routeStack.last!
    }
}

enum Route: Equatable {
    case userFeed
    case userMetrics
    case userEdit
    
    case editor(RouteEditor = RouteEditor.workout)
    
    case subscriptionFeed
}

enum RouteEditor: Equatable {
    case workout
    case runTracker
    case template(RouteEditorTemplate = RouteEditorTemplate.list)
    
    static func isOneOf(route: Route) -> Bool {
        switch route {
        case .editor(_):
            return true
        default:
            return false
        }
    }
}

enum RouteEditorTemplate {
    case list
    case create
    case edit
    
    static func isOneOf(route: Route) -> Bool {
        switch route {
        case .editor(.template(_)):
            return true
        default:
            return false
        }
    }
}
