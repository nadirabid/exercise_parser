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
    @State var index = 0
    @State var pageZeroSize: CGSize = .zero
    @State var pageOneSize: CGSize = .zero
    @State private var offset: CGFloat = 0
    @State private var isUserSwiping: Bool = false
    
    var body: some View {
        return VStack(alignment: .leading) {
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
            
            if index == 0 {
                if self.workout.location != nil {
                    MapView(location: self.workout.location!)
                        .frame(height: CGFloat(130.0))
                }
                
                VStack(spacing: 0) {
                    ForEach(self.workout.exercises) { exercise in
                        if exercise.type != "unknown" {
                            ExerciseView(exercise: exercise)
                        } else {
                            ProcessingExerciseView(exercise: exercise)
                        }
                    }
                }
                    .padding([.leading, .trailing])
            } else {
                WorkoutMuscleMetricsView(workout: self.workout)
            }
            
            HStack(spacing: 8) {
                Spacer()
                
                CircleButton(isSelected: Binding<Bool>(get: { self.index == 0 }, set: { _ in })) {
                    withAnimation(Animation.default.speed(2)) {
                        self.index = 0
                    }
                }
                
                CircleButton(isSelected: Binding<Bool>(get: { self.index == 1 }, set: { _ in })) {
                    withAnimation(Animation.default.speed(2)) {
                        self.index = 1
                    }
                }
                
                Spacer()
            }
        }
            .padding([.top, .bottom])
    }
}

struct CircleButton: View {
    @Binding var isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }) { Circle()
            .frame(width: 16, height: 16)
            .foregroundColor(self.isSelected ? appColor : appColor.opacity(0.5))
        }
    }
}

struct WorkoutMuscleMetricsView: View {
    @EnvironmentObject var exerciseDictionaryAPI: ExerciseDictionaryAPI
    
    var workout: Workout
    
    @State private var dictionaries: [ExerciseDictionary]?
    
    func loadWorkoutDictionaries() {
        _ = exerciseDictionaryAPI.getWorkoutDictionaries(id: workout.id!) { (response) in
            self.dictionaries = response.results
        }
    }
    
    func getDictionaryFor(exercise: Exercise) -> ExerciseDictionary? {
        dictionaries?.first { $0.id == exercise.exerciseDictionaryID }
    }
    
    var resolvedExercises: [Exercise] {
        workout.exercises.filter { $0.exerciseDictionaryID != nil }
    }
    
    var targetMuscles: [Muscle] {
        if dictionaries == nil {
            return []
        }

        return self.resolvedExercises.flatMap { (e) -> [Muscle] in
            let dictionary = self.getDictionaryFor(exercise: e)
            let muscleStrings = dictionary!.muscles.target?.map { s in s.lowercased() } ?? []
            
            return muscleStrings.flatMap { (muscleString) -> [Muscle] in
                let muscles = Muscle.allCases.filter { muscle in
                    if muscleString == muscle.name.lowercased() {
                        return true
                    } else if muscle.synonyms.map({ s in s.lowercased() }).contains(muscleString) {
                        return true
                    }
                    
                    return false
                }
                
                return muscles.flatMap { muscle -> [Muscle] in
                    if muscle.isMuscleGroup {
                        return muscle.components
                    } else {
                        return [muscle]
                    }
                }
            }
        }
    }
    
    var synergistMuscles: [Muscle] {
        if dictionaries == nil {
            return []
        }
        
        return self.resolvedExercises.flatMap { (e) -> [Muscle] in
            let dictionary = self.getDictionaryFor(exercise: e)
            let muscleStrings = dictionary!.muscles.synergists?.map { s in s.lowercased() } ?? []
 
            return muscleStrings.flatMap { (muscleString) -> [Muscle] in
                let muscles = Muscle.allCases.filter { muscle in
                    if muscleString == muscle.name.lowercased() {
                        return true
                    } else if muscle.synonyms.map({ s in s.lowercased() }).contains(muscleString) {
                        return true
                    }
                    
                    return false
                }
                
                return muscles.flatMap { muscle -> [Muscle] in
                    if muscle.isMuscleGroup {
                        return muscle.components
                    } else {
                        return [muscle]
                    }
                }
            }
        }
    }
    
    var body: some View {
        print(targetMuscles)
        print(synergistMuscles)
        return HStack(alignment: .center, spacing: 0) {
            AnteriorView(
                activatedPrimaryMuscles: self.targetMuscles,
                activiatedSecondaryMuscles: self.synergistMuscles
            )
            
            PosteriorView(
                activatedPrimaryMuscles: self.targetMuscles,
                activiatedSecondaryMuscles: self.synergistMuscles
            )
        }
            .frame(height: 280)
            .padding(.all, 0)
            .onAppear {
                self.loadWorkoutDictionaries()
            }
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
