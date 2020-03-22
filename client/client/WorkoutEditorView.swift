//
//  WorkoutEditorView.swift
//  client
//
//  Created by Nadir Muzaffar on 10/12/19.
//  Copyright © 2019 Nadir Muzaffar. All rights reserved.
//

import SwiftUI
import Introspect
import Combine
import Alamofire
import MapKit

// TODO: add on text change - re resolve the exercise w/ some debounce

public struct WorkoutEditorView: View {
    @EnvironmentObject var route: RouteState
    @EnvironmentObject var state: WorkoutEditorState
    @EnvironmentObject var workoutAPI: WorkoutAPI
    
    @ObservedObject private var stopWatch: Stopwatch = Stopwatch()
    @ObservedObject private var locationManager: LocationManager = LocationManager()
    
    @State private var workoutDataTaskPublisher: AnyCancellable? = nil
    @State private var textFieldContext: UITextField? = nil
    
    private var date: Date = Date()
    
    init() {
        stopWatch.start()
    }
    
    func pressStop() {
        self.stopWatch.stop()
        self.state.isStopped = true
    }
    
    func pressResume() {
        self.stopWatch.start()
        self.state.isStopped = false
    }
    
    func pressFinish() {
        let coord: CLLocationCoordinate2D? = locationManager.lastLocation?.coordinate
        let location = coord != nil ? Location(latitude: coord!.latitude, longitude: coord!.longitude) : nil
        let exercises: [Exercise] = state.activities.map{ a in Exercise(raw: a.input) }
        let workout = Workout(
            name: state.workoutName,
            date: self.date,
            exercises: exercises,
            location: location,
            secondsElapsed: stopWatch.counter
        )
        
        if exercises.count == 0 {
            self.state.reset()
            self.route.current = .feed
            return
        }
        
        workoutAPI.createWorkout(workout: workout) { (_) in
            self.state.reset()
            self.route.current = .feed
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                
                Button(action: {
                    // TODOOOOO
                }) {
                    Text("Hide")
                }
                .padding(.trailing)
            }
        
            Divider()
            
            HStack {
                Spacer()
                
                Text(self.stopWatch.convertCountToTimeString())
                    .font(.title)
                    .allowsTightening(true)
                
                Spacer()
            }
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(state.activities, id: \.id) { activity in
                        ExerciseEditorView(activity: activity, textFieldContext: self.textFieldContext)
                    }
                    
                    TextField("New entry", text: $state.newEntry, onCommit: {
                        self.state.newEntry = self.state.newEntry.trimmingCharacters(in: .whitespaces)
                        
                        if !self.state.newEntry.isEmpty {
                            let userActivity = UserActivity(input: self.state.newEntry)
                            self.state.activities.append(userActivity)
                            
                            self.state.newEntry = ""
                            self.textFieldContext = nil
                        }
                    })
                    .introspectTextField { textField in
                        if self.textFieldContext == nil {
                            textField.becomeFirstResponder()
                        }
                        self.textFieldContext = textField
                    }
                    .padding([.leading, .trailing])
                }
            }

            Spacer()
            
            HStack {
                Spacer()
                
                if !state.isStopped {
                    Button(action: self.pressStop) {
                        ZStack {
                            Circle()
                                .fill(appColor)
                                .shadow(color: Color.gray.opacity(0.3), radius: 1.0)
                                .frame(width: 70, height: 70)
                            
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .stroke(lineWidth: 2)
                                .fill(Color.white)
                                .frame(width: 14, height: 14)
                        }
                    }
                }
                else {
                    Button(action: self.pressResume) {
                        ZStack {
                            Circle()
                                .stroke(appColor, lineWidth: 4)
                                .shadow(color: Color.gray.opacity(0.3), radius: 1.0)
                                .frame(width: 70, height: 70)
                            
                            Text("Resume")
                                .font(.caption)
                                .foregroundColor(appColor)
                        }
                    }
                    
                    Button(action: self.pressFinish) {
                        ZStack {
                            Circle()
                                .fill(appColor)
                                .shadow(color: Color.gray.opacity(0.3), radius: 1.0)
                                .frame(width: 70, height: 70)
                            
                            Text("Finish")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                }
                
                Spacer()
            }
        }
    }
}

#if DEBUG
struct WorkoutEditorView_Previews : PreviewProvider {
    static var previews: some View {
        return WorkoutEditorView()
            .edgesIgnoringSafeArea(.bottom)
            .environmentObject(WorkoutEditorState())
            .environmentObject(RouteState(current: .editor))
            .environmentObject(MockWorkoutAPI(userState: UserState()) as WorkoutAPI)
            .environmentObject(MockExerciseAPI(userState: UserState()) as ExerciseAPI)
    }
}
#endif
