//
//  WorkoutTypeSelectorView.swift
//  client
//
//  Created by Nadir Muzaffar on 6/6/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

enum WorkoutType {
    case workout
    case routine
    case run
}

struct WorkoutTypeSelectorView: View {
    @EnvironmentObject var routerState: RouteState
    
    @State var disableCloseButton = false
    
    @State private var previousRoute: Route = .editor(.workout)
    @State private var workoutType: WorkoutType = .routine
    @State private var previousWorkoutType: WorkoutType = .workout
    @State private var workoutTypeConfirmed = false
    
    private var locationManager: RunTrackerLocationManager = RunTrackerLocationManager()
    
    var blurRadius: CGFloat {
        if workoutTypeConfirmed {
            return 0
        } else {
            return 3
        }
    }
    
    var runTrackerTransition: AnyTransition {
        if previousWorkoutType == .workout {
            return .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
        } else if previousWorkoutType == .routine {
            return .asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))
        }
        
        return AnyTransition.identity
    }
    
    var body: some View {
        // TODO: disable locationManager if workout is confirmed?

        return ZStack {
            ZStack {
                if routerState.peek() == .editor(.workout) {
                    WorkoutCreateView(disabled: !workoutTypeConfirmed)
                        .blur(radius: blurRadius)
                        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
                        .animation(.default)
                } else if routerState.peek() == .editor(.runTracker) {
                    if !workoutTypeConfirmed {
                        RunTrackerMapView(locationManager: self.locationManager, userTrackingMode: .none)
                            .blur(radius: blurRadius)
                            .transition(runTrackerTransition)
                            .animation(.default)
                            .onAppear {
                                self.locationManager.startUpdatingLocation()
                            }
                            .onDisappear {
                                if self.workoutType != .run { // apparently onDisappaer can be called way way AFTER RunTrackerView is shown - so dont wanna stop location manager if run has started
                                    self.locationManager.stopUpdatingLocation()
                                }
                            }
                    } else  {
                        RunTrackerView(locationManager: locationManager)
                    }
                } else if RouteEditorTemplate.isOneOf(route: routerState.peek()) {
                    WorkoutTemplatesListView(disableCloseButton: $disableCloseButton)
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        .animation(.default)
                }
                
                if !workoutTypeConfirmed && !RouteEditorTemplate.isOneOf(route: routerState.peek()) {
                    WorkoutSelectionInformationOverlay(
                        locationManager: self.locationManager
                    )
                }
            }
            
            if !workoutTypeConfirmed && !disableCloseButton && routerState.peek() != .editor(.template(.create)) { // IM HEREE - dont show close button
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            self.routerState.clearAndSet(route: .userFeed)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .padding([.top, .trailing], 24)
                        }
                        .padding(.leading)
                    }
                    
                    Spacer()
                }
                .statusBar(hidden: true)
                .edgesIgnoringSafeArea(.all)
                
                WorkoutTypeSelectorButtonsView(
                    locationManager: locationManager,
                    previousRoute: $previousRoute,
                    workoutTypeConfirmed: $workoutTypeConfirmed
                )
            }
        }
    }
}

struct WorkoutSelectionInformationOverlay: View {
    @EnvironmentObject var routerState: RouteState
    @ObservedObject var locationManager: RunTrackerLocationManager
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            HStack(spacing: 0) {
                Spacer()
                
                Text("00")
                    .font(.largeTitle)
                    .foregroundColor(appColor)
                Text("h")
                    .font(.headline)
                    .foregroundColor(appColor)
                Text("00")
                    .font(.largeTitle)
                    .foregroundColor(appColor)
                Text("m")
                    .font(.headline)
                    .foregroundColor(appColor)
                Text("00")
                    .font(.largeTitle)
                    .foregroundColor(appColor)
                Text("s")
                    .font(.headline)
                    .foregroundColor(appColor)
                
                Spacer()
            }
            .padding(.bottom, 6)
            
            if routerState.peek() == .editor(.workout) {
                Text("WORKOUT")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(appColor)
            } else if routerState.peek() == .editor(.runTracker) {
                Text("RUN")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(appColor)
                
                if !locationManager.isLocationEnabled {
                    Button(action: {
                        UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                    }) {
                        Text("LOCATION SERVICES REQUIRED")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(appColor)
                    }
                }
            }
            
            Spacer()
            Spacer()
        }
    }
}

struct WorkoutTypeSelectorButtonsView: View {
    @EnvironmentObject var routerState: RouteState
    @ObservedObject var locationManager: RunTrackerLocationManager
    
    @Binding var previousRoute: Route
    @Binding var workoutTypeConfirmed: Bool
    
    var startButtonColor: Color {
        if routerState.peek() == .editor(.runTracker) && !locationManager.isLocationEnabled {
            return Color.secondary
        } else {
            return appColor
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                Divider()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        self.previousRoute = self.routerState.peek()
                        self.routerState.replaceCurrent(with: .editor(.workout))
                    }) {
                        DumbbellIconShape()
                            .fill(self.routerState.peek() == .editor(.workout) ? appColor : Color.secondary)
                            .frame(width: 50, height: 20)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.previousRoute = self.routerState.peek()
                        self.routerState.replaceCurrent(with: .editor(.runTracker))
                    }) {
                        RunningIconShape()
                            .fill(self.routerState.peek() == .editor(.runTracker) ? appColor : Color.secondary)
                            .frame(width: 50, height: 20)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.previousRoute = self.routerState.peek()
                        self.routerState.replaceCurrent(with: .editor(.template(.list)))
                    }) {
                        ClipboardIconShape()
                            .fill(self.routerState.peek() == .editor(.template(.list)) ? appColor : Color.secondary)
                            .frame(width: 50, height: 20)
                    }
                    
                    Spacer()
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding([.bottom, .top])
                
                if self.routerState.peek() != .editor(.template(.create)) {  // This start button should exist in the overlay view
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            self.workoutTypeConfirmed = true
                        }) {
                            Text("START")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .foregroundColor(Color.white)
                                .padding()
                                .background(
                                    Circle()
                                        .scaledToFill()
                                        .foregroundColor(startButtonColor)
                                )
                        }
                        .padding([.bottom, .top])
                        .disabled(self.routerState.peek() == .editor(.runTracker) ? !locationManager.isLocationEnabled : false)
                        
                        Spacer()
                    }
                    .transition(.scale)
                }
            }
            .padding(.bottom)
            .padding(.bottom)
            .background(Color(UIColor.systemBackground))
            
        }
        .edgesIgnoringSafeArea(.all)
    }
}
