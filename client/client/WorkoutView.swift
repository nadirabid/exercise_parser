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

struct WorkoutView: View {
    @State var workout: Workout
    
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
                    ActivityView(exercise: exercise)
                }
            }
        }
    }
}

#if DEBUG
struct WorkoutView_Previews : PreviewProvider {
    static var previews: some View {
        List {
            WorkoutView(workout: Workout(id: 1, createdAt: "", updatedAt: "", name: "", date: "", exercises: []))
            WorkoutView(workout: Workout(id: 1, createdAt: "", updatedAt: "", name: "", date: "", exercises: []))
            WorkoutView(workout: Workout(id: 1, createdAt: "", updatedAt: "", name: "", date: "", exercises: []))
        }
    }
}
#endif
