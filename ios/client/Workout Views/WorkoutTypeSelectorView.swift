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
    @ObservedObject var locationManager: RunTrackerLocationManager = RunTrackerLocationManager()
    
    @State private var workoutType: WorkoutType = .run
    @State private var workoutTypeConfirmed = true
    
    var blurRadius: CGFloat {
        if workoutTypeConfirmed {
            return 0
        } else {
            return 3
        }
    }
    
    var isLocationEnabled: Bool {
        switch locationManager.locationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        case .notDetermined, .restricted, .denied:
            return false
        default:
            return false
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
                    RunTrackerView(disabled: !workoutTypeConfirmed, locationManager: locationManager)
                        .blur(radius: blurRadius)
                        .transition(
                            .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
                        )
                        .animation(.default)
                }
             
                if !workoutTypeConfirmed {
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
                        
                        if workoutType == .workout {
                            Text("WORKOUT")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(appColor)
                        } else if workoutType == .run {
                            Text("RUN")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(appColor)
                            
                            if !isLocationEnabled {
                                Text("LOCATION SERVICES REQUIRED")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(appColor)
                            }
                        }
                        
                        Spacer()
                        Spacer()
                    }
                }
            }
            
            if !workoutTypeConfirmed {
                WorkoutTypeSelectorButtonsView(
                    workoutType: $workoutType,
                    workoutTypeConfirmed: $workoutTypeConfirmed,
                    isLocationEnabled: isLocationEnabled
                )
            }
        }
    }
}

struct WorkoutTypeSelectorButtonsView: View {
    @Binding var workoutType: WorkoutType
    @Binding var workoutTypeConfirmed: Bool
    
    let isLocationEnabled: Bool
    
    var startButtonColor: Color {
        if workoutType == .run && !isLocationEnabled {
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
                        .disabled(!isLocationEnabled)
                    
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
            workoutType: workoutType,
            workoutTypeConfirmed: workoutTypeConfirmed,
            isLocationEnabled: true
        ).padding()
    }
}
