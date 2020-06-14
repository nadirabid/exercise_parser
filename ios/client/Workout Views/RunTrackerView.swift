//
//  RunTrackerView.swift
//  client
//
//  Created by Nadir Muzaffar on 6/7/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI
import MapKit

struct RunTrackerView: View {
    @EnvironmentObject var routeState: RouteState
    @EnvironmentObject var workoutAPI: WorkoutAPI
    @EnvironmentObject var locationAPI: LocationAPI
    
    @State var isStopped: Bool = false
    @State var workout: Workout? = nil
    @State var workoutName: String = ""
    
    var locationManager: RunTrackerLocationManager
    var stopwatch: Stopwatch = Stopwatch()
    
    private let isDisabled: Bool
    
    init(disabled: Bool, locationManager _locationManager: RunTrackerLocationManager) {
        locationManager = _locationManager
        isDisabled = disabled
        
        if !disabled {
            if !self.isStopped {
                stopwatch.start()
                self.locationManager.startTrackingLocation()
            } else {
                stopwatch.stop()
                self.locationManager.stopTrackingLocation()
            }
        }
        
        self.locationManager.startUpdatingLocation()
    }
    
    func createWorkout() {
        #if targetEnvironment(simulator)
        let location = Location(latitude: 37.34727983131215, longitude: -121.88308869874288)
        #else
        let coord = locationManager.lastLocation?.coordinate
        let location = coord != nil ? Location(latitude: coord!.latitude, longitude: coord!.longitude, exerciseID: nil, index: nil) : nil
        #endif
        
        let workout = Workout(
            name: dateToWorkoutName(Date()),
            date: Date(),
            exercises: [Exercise()],
            location: location,
            secondsElapsed: stopwatch.counter,
            inProgress: true
        )
        
        workoutAPI.createWorkout(workout: workout) { (workout) in
            self.workout = workout

            self.locationManager.locationUpdateHandler = { (index, coord) in
                if !self.locationManager.isTrackingPath { return }

                guard let exercise = workout.exercises.first else { return }
                
                let location = Location(
                    latitude: coord.latitude,
                    longitude: coord.longitude,
                    exerciseID: exercise.id,
                    index: index
                )
                
                _ = self.locationAPI.createLocation(location)
            }
        }
    }
    
    func completeWorkout() {
        let workout = Workout(
            id: self.workout!.id!,
            name: self.workoutName == "" ? dateToWorkoutName(Date()) : self.workoutName,
            secondsElapsed: stopwatch.counter,
            inProgress: false
        )
        
        workoutAPI
            .updateWorkoutAsComplete(workout)
            .then { _ in
                self.locationManager.stopUpdatingLocation()
                self.routeState.replaceCurrent(with: .userFeed)
            }
    }
    
    var body: some View {
        return GeometryReader { geometry in
            VStack {
                RunTrackerMapView(locationManager: self.locationManager)
                    .animation(.none)
                
                VStack(alignment: .leading, spacing: 0) {
                    RunTrackerMetaMetricsView(
                        locationManager: self.locationManager,
                        stopwatch: self.stopwatch,
                        runName: self.$workoutName,
                        isStopped: self.isStopped,
                        width: geometry.size.width
                    )
                    
                    if self.isStopped {
                        Divider()
                    }
                    
                    HStack(spacing: 0) {
                        if !self.isStopped {
                            Spacer()
                            
                            Button(action: {
                                self.isStopped = true
                                self.locationManager.stopTrackingLocation()
                                self.stopwatch.stop()
                            }) {
                                Image(systemName: "stop.circle")
                                    .font(.largeTitle)
                                    .foregroundColor(appColor)
                            }
                            
                            Spacer()
                        } else {
                            Button(action: {
                                self.completeWorkout()
                            }) {
                                Text("Save")
                                    .foregroundColor(Color.secondary)
                                    .animation(.none)
                            }
                            .frame(width: geometry.size.width / 2)
                            
                            Divider()
                            
                            Button(action: {
                                self.isStopped = false
                                self.locationManager.startTrackingLocation()
                                self.stopwatch.start()
                                
                                UIApplication.shared.endEditing()
                            }) {
                                Text("Resume")
                                    .foregroundColor(Color.secondary)
                                    .animation(.none)
                            }
                            .frame(width: geometry.size.width / 2)
                        }
                    }
                    .padding([.top, .bottom])
                    .fixedSize(horizontal: false, vertical: true)
                }
                .background(Color(UIColor.systemBackground))
            }
            .keyboardObserving()
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            if !self.isDisabled {
                self.createWorkout()
            }
        }
    }
}

// extension for keyboard to dismiss
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

public struct RunTrackerMetaMetricsView: View {
    @EnvironmentObject var userState: UserState
    
    @ObservedObject var locationManager: RunTrackerLocationManager
    @ObservedObject var stopwatch: Stopwatch
    @Binding var runName: String
    
    var isStopped: Bool = false
    var width: CGFloat = 0
    
    var totalDistance: String {
        let d = locationManager.currentDistance
        let m = Measurement(value: d, unit: UnitLength.meters)
        
        if m.converted(to: UnitLength.feet).value >= 500 {
            let v = m.converted(to: UnitLength.miles).value
            return String(format: "%.1f", round(v*100) / 100)
        }
        
        let v = m.converted(to: UnitLength.feet).value
        return String(format: "%.1f", round(v*100) / 100)
    }
    
    var distanceUnits: String {
        let d = locationManager.currentDistance
        let m = Measurement(value: d, unit: UnitLength.meters)
        
        if m.converted(to: UnitLength.feet).value >= 500 {
            return UnitLength.miles.symbol
        }
        
        return UnitLength.feet.symbol
    }
    
    var pace: Double {
        let p = calculatePace(distance: locationManager.currentDistance, seconds: Double(stopwatch.counter))
    
        return p
    }
    
    var userWeight: Double {
        if self.userState.userInfo.weight > 0 {
            return Double(self.userState.userInfo.weight)
        }
        
        return 80
    }
    
    var calories: Double {        
        let met = metFromPace(pace: self.pace)
        return calculateCalsFromStandardMET(
            met: met,
            weightKg: userWeight,
            seconds: Double(stopwatch.counter)
        )
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            if !self.isStopped {
                HStack(spacing: 0) {
                    WorkoutDetail(
                        name: "Time",
                        value: secondsToElapsedTimeString(self.stopwatch.counter)
                    )
                        .padding([.leading, .trailing])
                        .frame(width: self.width / 2, alignment: .center)
                    
                    Divider()
                    
                    WorkoutDetail(
                        name: "Distance",
                        value: "\(self.totalDistance) \(self.distanceUnits)"
                    )
                        .padding([.leading, .trailing])
                        .frame(width: self.width / 2, alignment: .center)
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top)
            } else {
                Text("Workout name")
                    .font(.caption)
                    .padding([.leading, .top])
                    .padding(.bottom, 3)
                    .foregroundColor(Color.gray)
                
                TextField(dateToWorkoutName(Date()), text: self.$runName)
                    .padding([.leading, .trailing])
                    .padding([.top, .bottom], 12)
                    .background(Color(#colorLiteral(red: 0.9813412119, green: 0.9813412119, blue: 0.9813412119, alpha: 1)))
                    .border(Color(#colorLiteral(red: 0.9160850254, green: 0.9160850254, blue: 0.9160850254, alpha: 1)))
                    .introspectTextField { (textField: UITextField) in
                        textField.becomeFirstResponder()
                }
                
                VStack {
                    HStack(spacing: 0) {
                        VStack(alignment: .center) {
                            Text("Time")
                                .foregroundColor(Color.secondary)
                                .fixedSize()
                            
                            Text(secondsToElapsedTimeString(self.stopwatch.counter))
                                .font(.title)
                                .allowsTightening(false)
                                .fixedSize()
                        }
                        .padding([.leading, .trailing])
                        .frame(width: self.width / 2, alignment: .center)
                        
                        Divider()
                        
                        VStack(alignment: .center) {
                            Text("Calories").foregroundColor(Color.secondary)
                            Text(String(format: "%.0f", self.calories)).font(.title)
                        }
                        .padding([.leading, .trailing])
                        .frame(width: self.width / 2, alignment: .center)
                    }
                    .fixedSize()
                    
                    HStack(spacing: 0) {
                        VStack(alignment: .center) {
                            Text("Distance").foregroundColor(Color.secondary)
                            
                            Text("\(self.totalDistance) \(self.distanceUnits)")
                                .font(.title)
                                .fixedSize()
                        }
                        .padding([.leading, .trailing])
                        .frame(width: self.width / 2, alignment: .center)
                        
                        Divider()
                        
                        VStack(alignment: .center) {
                            Text("Pace").foregroundColor(Color.secondary)
                            
                            Text("\(String(format: "%.1f", self.pace)) mph").font(.title)
                        }
                        .padding([.leading, .trailing])
                        .frame(width: self.width / 2, alignment: .center)
                    }
                    .fixedSize()
                }
                .padding([.top, .bottom])
            }
        }
    }
}

func calculatePace(distance: Double, seconds: Double) -> Double {
    if seconds == 0 {
        return 0
    }
    
    let dm = Measurement(value: distance, unit: UnitLength.meters)
    let sm = Measurement(value: seconds, unit: UnitDuration.seconds)
    
    let pace = dm.converted(to: UnitLength.miles).value / sm.converted(to: UnitDuration.hours).value
    
    return pace
}

func metFromPace(pace: Double) -> Double {
    if pace <= 4 {
        return 6
    } else if pace <= 5 {
        return 8.3
    } else if pace <= 5.2 {
        return 9.0
    } else if pace <= 6 {
        return 9.8
    } else if pace <= 6.7 {
        return 10.5
    } else if pace <= 7 {
        return 11.0
    } else if pace <= 7.5 {
        return 11.5
    } else if pace <= 8 {
        return 11.8
    } else if pace <= 8.6 {
        return 12.3
    } else if pace <= 9 {
        return 12.8
    } else if pace <= 10 {
        return 14.5
    } else if pace <= 11 {
        return 16.0
    } else if pace <= 12 {
        return 19.0
    } else if pace <= 13 {
        return 19.8
    } else if pace <= 14 {
        return 23
    } else {
        return 23 // compendium data maxes out at 23 (14/mph)
    }
}

func calculateCalsFromStandardMET(met: Double, weightKg: Double, seconds: Double) -> Double {
    return met * weightKg * (seconds / (60 * 60))
}

func calculateCalsFromCorectedMET(met: Double, weightKg: Double, heightCm: Double, ageYr: Double, seconds: Double, male: Bool) -> Double {
    if male {
        return met * calculateMaleBMR(weightKg: weightKg, heightCm: heightCm, ageYr: ageYr) * (seconds / (24 * 60 * 60))
    }
    
    return met * calculateFemaleBMR(weightKg: weightKg, heightCm: heightCm, ageYr: ageYr) * (seconds / (24 * 60 * 60))
}

func calculateMaleBMR(weightKg: Double, heightCm: Double, ageYr: Double) -> Double {
    return (10 * weightKg) + (6.5 * heightCm) - (5 * ageYr) + 5
}

func calculateFemaleBMR(weightKg: Double, heightCm: Double, ageYr: Double) -> Double {
    return (10 * weightKg) + (6.5 * heightCm) - (5 * ageYr) - 161
}

struct RunTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        RunTrackerView(disabled: true, locationManager: RunTrackerLocationManager())
    }
}
