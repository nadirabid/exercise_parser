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
    
    @State private var workoutType: WorkoutType = .workout
    @State private var workoutTypeConfirmed = false
    
    private var locationManager: RunTrackerLocationManager = RunTrackerLocationManager()
    
    var blurRadius: CGFloat {
        if workoutTypeConfirmed {
            return 0
        } else {
            return 3
        }
    }
    
    var body: some View {
        // TODO: disable locationManager if workout is confirmed?
        ZStack {
            ZStack {
                if workoutType == .workout {
                    WorkoutCreateView(disabled: !workoutTypeConfirmed)
                        .blur(radius: blurRadius)
                        .transition(
                            .asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))
                    )
                        .animation(.default)
                } else if workoutType == .run {
                    if !workoutTypeConfirmed {
                        RunTrackerMapView(locationManager: self.locationManager, userTrackingMode: .none)
                            .blur(radius: blurRadius)
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                            .animation(.default)
                    } else  {
                        RunTrackerView(locationManager: locationManager)
                    }
                }
                
                if !workoutTypeConfirmed {
                    WorkoutSelectionInformationOverlay(
                        locationManager: self.locationManager,
                        workoutType: self.workoutType
                    )
                }
            }
            
            if !workoutTypeConfirmed {
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            self.routerState.pop()
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
                    workoutType: $workoutType,
                    workoutTypeConfirmed: $workoutTypeConfirmed
                )
            }
        }
    }
}

struct WorkoutSelectionInformationOverlay: View {
    @ObservedObject var locationManager: RunTrackerLocationManager
    var workoutType: WorkoutType
    
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
            
            if workoutType == .workout {
                Text("WORKOUT")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(appColor)
            } else if workoutType == .run {
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
    @ObservedObject var locationManager: RunTrackerLocationManager
    
    @Binding var workoutType: WorkoutType
    @Binding var workoutTypeConfirmed: Bool
    
    var startButtonColor: Color {
        if workoutType == .run && !locationManager.isLocationEnabled {
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
                        self.workoutType = .workout
                    }) {
                        DumbbellIconShape()
                            .fill(workoutType == .workout ? appColor : Color.secondary)
                            .frame(width: 50, height: 20)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.workoutType = .run
                    }) {
                        RunningIconShape()
                            .fill(workoutType == .run ? appColor : Color.secondary)
                            .frame(width: 50, height: 20)
                    }
                    
                    Spacer()
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding([.bottom, .top])
                
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
                    .disabled(!locationManager.isLocationEnabled)
                    
                    Spacer()
                }
            }
            .background(Color(UIColor.systemBackground))
            .padding(.bottom)
            .padding(.bottom)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct WorkoutSelectorButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        let workoutType = Binding<WorkoutType>(
            get: { WorkoutType.routine },
            set: { _ in }
        )
        
        let workoutTypeConfirmed = Binding<Bool>(
            get: { false },
            set: { _ in }
        )
        
        return WorkoutTypeSelectorButtonsView(
            locationManager: RunTrackerLocationManager(),
            workoutType: workoutType,
            workoutTypeConfirmed: workoutTypeConfirmed
        ).padding()
    }
}
