//
//  ContentView.swift
//  client
//
//  Created by Nadir Muzaffar on 6/15/19.
//  Copyright © 2019 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct WorkoutDetail: View {
    let name: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(self.name.uppercased())
                .font(.caption)
                .fontWeight(.heavy)
                .fixedSize()
            Text(self.value)
                .fixedSize()
        }
    }
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
                     
                     if workout.date != nil {
                         Text(workout.date!.getHumanFriendlyString())
                             .font(.caption)
                             .foregroundColor(.secondary)
                     }
                 }
                 .fixedSize()
                 
                 Spacer()
             }
             .padding([.leading, .trailing])
            
            HStack(spacing: 10) {
                WorkoutDetail(name: "MAR", value: "20")
                Divider()
                WorkoutDetail(name: "Time", value: "2:23:32")
                Divider()
                WorkoutDetail(name: "Exercises", value: "7")
                Spacer()
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding([.leading, .trailing])
            
            if workout.location != nil {
                MapView(location: workout.location!)
                    .frame(height: CGFloat(130.0))
            }
            
            VStack {
                ForEach(workout.exercises) { exercise in
                    ActivityView(exercise: exercise)
                }
            }
            .padding([.leading, .trailing])
        }
        .padding([.top, .bottom])
    }
}

#if DEBUG
struct WorkoutView_Previews : PreviewProvider {
    static var previews: some View {
        WorkoutView(
            workout: Workout(
                id: 1,
                createdAt: "",
                updatedAt: "",
                name: "Morning workout",
                date: Date(),
                exercises: [
                    Exercise(
                        id: 1,
                        createdAt: "",
                        updatedAt: "",
                        name: "Curls",
                        type: "weighted",
                        raw: "1x3 curls",
                        weightedExercise: WeightedExercise(sets: 1, reps: 3),
                        distanceExercise: nil
                    ),
                    Exercise(
                        id: 2,
                        createdAt: "",
                        updatedAt: "",
                        name: "Benchpress",
                        type: "weighted",
                        raw: "4 sets of 3 of benchpress",
                        weightedExercise: WeightedExercise(sets: 4, reps: 3),
                        distanceExercise: nil
                    )
                ],
                location: Location(latitude: 37.34727983131215, longitude: -121.88308869874288)
            )
        )
    }
}
#endif
