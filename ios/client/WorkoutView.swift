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
                .font(.callout)
                .fixedSize()
        }
    }
}

struct WorkoutView: View {
    @EnvironmentObject var userState: UserState
    @State var workout: Workout
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                CircleProfileImage().frame(width: 45, height: 45)
                
                VStack(alignment: .leading) {
                    Text(workout.name)
                    
                    Text(userState.getUserName())
                        .font(.caption)
                        .foregroundColor(Color.gray)
                }
            }
                .padding(.leading)
            
            WorkoutMetaMetricsView(workout: workout)
                .fixedSize(horizontal: true, vertical: true)
                .padding(.leading)
            
            if workout.location != nil {
                MapView(location: workout.location!)
                    .frame(height: CGFloat(130.0))
            }
            
            VStack(spacing: 0) {
                ForEach(workout.exercises) { exercise in
                    if exercise.type != "unknown" {
                        ExerciseView(exercise: exercise)
                    } else {
                        ProcessingExerciseView(exercise: exercise)
                    }
                }
            }
                .padding([.leading, .trailing])
        }
            .padding([.top, .bottom])
    }
}

public struct WorkoutMetaMetricsView: View {
    @State var workout: Workout
    
    var totalWeight: Int {
        let result = workout.exercises.reduce(Float.zero) { (r, e) in
            if let weightedExercise = e.weightedExercise {
                let total = weightedExercise.weightInDisplayUnits * Float(weightedExercise.reps) * Float(weightedExercise.sets)
                return total + r
            }
            
            return r
        }
        
        return Int(round(result))
    }
    
    var totalDistance: Int {
        let result = workout.exercises.reduce(Float.zero) { (r, e) in
            if let distanceExercise = e.distanceExercise {
                return r + distanceExercise.distanceInDisplayUnits
            }
            
            return r
        }
        
        return Int(round(result))
    }
    
    
    public var body: some View {
        HStack(spacing: 10) {
            WorkoutDetail(
                name: workout.date.abbreviatedMonthString,
                value: workout.date.dayString
            )
            
            Divider()
            
            WorkoutDetail(
                name: "Time",
                value: secondsToElapsedTimeString(workout.secondsElapsed)
            )
            
            Divider()

            WorkoutDetail(name: "Exercises", value: "\(workout.exercises.count)")
            
            Divider()
            
            WorkoutDetail(name: "Weight", value:"\(totalWeight) lbs")
            
            Divider()
            
            WorkoutDetail(name: "Distance", value:"\(totalDistance) mi")
        }
    }
}

#if DEBUG
struct WorkoutView_Previews : PreviewProvider {
    static var previews: some View {
        let userState = UserState()
        userState.userInfo = User(
            id: 1,
            externalUserId: "test.user",
            email: "test@user.com",
            givenName: "Calev",
            familyName: "Muzaffar"
        )
        
        return WorkoutView(
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
                        weightedExercise: WeightedExercise(sets: 1, reps: 3, weight: 10.3),
                        distanceExercise: nil
                    ),
                    Exercise(
                        id: 2,
                        createdAt: "",
                        updatedAt: "",
                        type: "unknown",
                        raw: "1x3 curls"
                    ),
                    Exercise(
                        id: 3,
                        createdAt: "",
                        updatedAt: "",
                        name: "Benchpress",
                        type: "weighted",
                        raw: "4 sets of 3 of benchpress",
                        weightedExercise: WeightedExercise(sets: 4, reps: 3, weight: 10),
                        distanceExercise: nil
                    )
                ],
                location: Location(latitude: 37.34727983131215, longitude: -121.88308869874288)
            )
        )
        .environmentObject(userState)
    }
}
#endif
