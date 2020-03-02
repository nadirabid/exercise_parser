//
//  ContentView.swift
//  client
//
//  Created by Nadir Muzaffar on 6/15/19.
//  Copyright © 2019 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct Activity {
    var name: String
    var units: [[String]]
}

struct ContentView: View {
    var workouts: [Activity] = [
        Activity(name: "Running", units: [["mi", "0.7"]]),
        Activity(name: "Rowing", units: [["m", "700"], ["mins", "4"]]),
        Activity(name: "Incline Benchpress", units: [["sets", "5"], ["reps", "5"], ["lbs", "95"]]),
        Activity(name: "Situps", units: [["reps", "60"]]),
        Activity(name: "Deadlift", units: [["sets", "5"], ["reps", "5"], ["lbs", "188"]])
    ]
    
    var body: some View {
        VStack {
            HStack {
                CircleProfileImage()
                    .frame(width: 45)
                
                VStack(alignment: .leading) {
                    Text("Morning workout")
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
                ForEach(workouts, id: \.name) { workout in
                    ActivityView(workout: workout)
                }
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        List {
            ContentView()
            ContentView()
            ContentView()
        }
    }
}
#endif
