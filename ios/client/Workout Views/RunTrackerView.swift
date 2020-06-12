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
    
    @State var isStopped: Bool = true
    @State var workout: Workout? = nil
    @State var workoutName: String = ""
    
    var locationManager: RunTrackerLocationManager
    var stopwatch: Stopwatch = Stopwatch()
    
    init(disabled: Bool, locationManager _locationManager: RunTrackerLocationManager) {
        locationManager = _locationManager
        locationManager.locationUpdateHandler = self.onLocationUpdate
        
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
    
    func onLocationUpdate(index: Int, location: CLLocationCoordinate2D) {
        guard let exercise = self.workout?.exercises.first else { return }
        guard let coord = locationManager.lastLocation?.coordinate else { return }
        
        let location = Location(
            latitude: coord.latitude,
            longitude: coord.longitude,
            exerciseID: exercise.id,
            index: index
        )
        
        _ = locationAPI.createLocation(location)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                RunTrackerMapView(locationManager: self.locationManager)
                    .animation(.none)
                
                VStack(alignment: .leading, spacing: 0) {
                    RunTrackerMetaMetricsView(stopwatch: self.stopwatch, runName: self.$workoutName, isStopped: self.isStopped, width: geometry.size.width)
                    
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
            self.createWorkout()
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
    @ObservedObject var stopwatch: Stopwatch
    @Binding var runName: String
    
    var isStopped: Bool = false
    var width: CGFloat = 0
    
    var totalDistance: Float {
        return 0
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
                        value: "\(self.totalDistance) mi"
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
                
                TextField("Wednesday workout", text: self.$runName)
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
                            Text("238").font(.title)
                        }
                        .padding([.leading, .trailing])
                        .frame(width: self.width / 2, alignment: .center)
                    }
                    .fixedSize()
                    
                    HStack(spacing: 0) {
                        VStack(alignment: .center) {
                            Text("Distance").foregroundColor(Color.secondary)
                            
                            Text("3.2 mi").font(.title)
                        }
                        .padding([.leading, .trailing])
                        .frame(width: self.width / 2, alignment: .center)
                        
                        Divider()
                        
                        VStack(alignment: .center) {
                            Text("Pace").foregroundColor(Color.secondary)
                            
                            Text("4:37 / mi").font(.title)
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

struct RunTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        RunTrackerView(disabled: true, locationManager: RunTrackerLocationManager())
    }
}
