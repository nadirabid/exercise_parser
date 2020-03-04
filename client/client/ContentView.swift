//
//  ContentView.swift
//  client
//
//  Created by Nadir Muzaffar on 6/15/19.
//  Copyright © 2019 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct ActivityViewModel {
    var name: String
    var units: [[String]]
}

struct ContentView: View {
    @State var workout: Workout
    var workouts: [ActivityViewModel] = [
        ActivityViewModel(name: "Running", units: [["mi", "0.7"]]),
        ActivityViewModel(name: "Rowing", units: [["m", "700"], ["mins", "4"]]),
        ActivityViewModel(name: "Incline Benchpress", units: [["sets", "5"], ["reps", "5"], ["lbs", "95"]]),
        ActivityViewModel(name: "Situps", units: [["reps", "60"]]),
        ActivityViewModel(name: "Deadlift", units: [["sets", "5"], ["reps", "5"], ["lbs", "188"]])
    ]
    
    var body: some View {
        VStack {
            HStack {
                CircleProfileImage()
                    .frame(width: 45)
                
                VStack(alignment: .leading) {
                    Text(workout.name)
                        .font(.headline)
                    
                    Text("Nov 19th, 2018")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .fixedSize()
                
                Spacer()
            }
            
            MapView()
                .frame(height: CGFloat(150.0))
            
            VStack {
                ForEach(workout.exercises) { exercise in
                    ActivityView(exercise: exercise, workout: self.workouts[0])
                }
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        List {
            ContentView(workout: Workout(id: 1, createdAt: "", updatedAt: "", name: "", date: "", exercises: []))
            ContentView(workout: Workout(id: 1, createdAt: "", updatedAt: "", name: "", date: "", exercises: []))
            ContentView(workout: Workout(id: 1, createdAt: "", updatedAt: "", name: "", date: "", exercises: []))
        }
    }
}
#endif
