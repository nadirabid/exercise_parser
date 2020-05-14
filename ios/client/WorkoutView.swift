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
    var user: User? = nil
    var workout: Workout
    var showUserInfo: Bool = true
    
    @State private var viewPage = 0
    
    var body: some View {
        return VStack(alignment: .leading) {
            HStack {
                if showUserInfo {
                    VStack {
                        UserIconShape().fill(Color.gray).padding()
                    }
                        .background(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: 45, height: 45)
                    
                    VStack(alignment: .leading) {
                        Text(workout.name)
                        
                        Text(user?.getUserName() ?? "")
                            .font(.caption)
                            .foregroundColor(Color.gray)
                    }
                } else {
                    Text(workout.name)
                }
            }
                .padding(.leading)
            
            WorkoutMetaMetricsView(workout: workout)
                .fixedSize(horizontal: true, vertical: true)
                .padding(.leading)
            
            if viewPage == 0 {
                if self.workout.location != nil {
                    MapView(location: self.workout.location!)
                        .frame(height: CGFloat(130.0))
                }
                
                VStack(spacing: 0) {
                    ForEach(self.workout.exercises) { exercise in
                        if exercise.resolutionType != "" {
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
                
                CircleButton(isSelected: Binding<Bool>(get: { self.viewPage == 0 }, set: { _ in })) {
                    withAnimation(Animation.default.speed(2)) {
                        self.viewPage = 0
                    }
                }
                
                CircleButton(isSelected: Binding<Bool>(get: { self.viewPage == 1 }, set: { _ in })) {
                    withAnimation(Animation.default.speed(2)) {
                        self.viewPage = 1
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
    
    var targetMuscles: [MuscleActivation] {
        if dictionaries == nil {
            return []
        }

        return self.resolvedExercises.flatMap { (e) -> [MuscleActivation] in
            let dictionary = self.getDictionaryFor(exercise: e)
            let muscleStrings = dictionary?.muscles.target?.map { s in s.lowercased() } ?? []
            
            return muscleStrings.flatMap { (muscleString) -> [MuscleActivation] in
                let muscles = Muscle.allCases.filter { muscle in
                    if muscleString == muscle.name.lowercased() {
                        return true
                    }
                    
                    return false
                }
                
                return muscles.flatMap { muscle -> [MuscleActivation] in
                    if muscle.isMuscleGroup {
                        return muscle.components.map { MuscleActivation(muscle: $0) }
                    } else {
                        return [MuscleActivation(muscle: muscle)]
                    }
                }
            }
        }
    }
    
    var synergistMuscles: [MuscleActivation] {
        if dictionaries == nil {
            return []
        }
        
        return self.resolvedExercises.flatMap { (e) -> [MuscleActivation] in
            let dictionary = self.getDictionaryFor(exercise: e)
            let muscleStrings = dictionary?.muscles.synergists?.map { s in s.lowercased() } ?? []
 
            return muscleStrings.flatMap { (muscleString) -> [MuscleActivation] in
                let muscles = Muscle.allCases.filter { muscle in
                    if muscleString == muscle.name.lowercased() {
                        return true
                    }
                    
                    return false
                }
                
                return muscles.flatMap { muscle -> [MuscleActivation] in
                    if muscle.isMuscleGroup {
                        return muscle.components.map { MuscleActivation(muscle: $0) }
                    } else {
                        return [MuscleActivation(muscle: muscle)]
                    }
                }
            }
        }
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            AnteriorView(
                activatedTargetMuscles: self.targetMuscles,
                activatedSynergistMuscles: self.synergistMuscles
            )
            
            PosteriorView(
                activatedTargetMuscles: self.targetMuscles,
                activatedSynergistMuscles: self.synergistMuscles
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
            let total =  e.data.displayWeightValue * Float(e.data.reps) * Float(e.data.sets)
            return total + r
        }
        
        return Int(round(result))
    }
    
    var totalDistanceUnits: String {
        let result = workout.exercises.reduce(Float.zero) { (r, e) in
             return r + e.data.distance
        }
        
        if result <= 300 {
            return UnitLength.feet.symbol
        }
        
        return UnitLength.miles.symbol
    }
    
    var totalDistance: Float {
        let result = workout.exercises.reduce(Float.zero) { (r, e) in
            return r + e.data.distance
        }
        
        var m = Measurement(value: Double(result), unit: UnitLength.meters)
        
        if result <= 300 {
            m = m.converted(to: UnitLength.feet)
        } else {
            m = m.converted(to: UnitLength.miles)
        }
        
        return Float(round(m.value*100)/100)
    }
    
    var totalReps: Int {
        let result = workout.exercises.reduce(Int.zero) { (r, e) in
            return r + e.data.reps
        }
        
        return result
    }
    
    var totalSets: Int {
        let result = workout.exercises.reduce(Int.zero) { (r, e) in
            return r + e.data.sets
        }
        
        return result
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
            
            if totalSets > 0 {
                Divider()
                
                WorkoutDetail(name: "Sets", value:"\(totalSets.description)")
            }
            
            if totalReps > 0 {
                Divider()
                
                WorkoutDetail(name: "Reps", value:"\(totalReps.description)")
            }
            
            if totalDistance > 0 {
                Divider()
                
                WorkoutDetail(name: "Distance", value: "\(totalDistance) \(totalDistanceUnits)")
            }
        }
    }
}

#if DEBUG
struct WorkoutView_Previews : PreviewProvider {
    static var previews: some View {
        return WorkoutView(
            user: User(
                id: 1,
                externalUserId: "test.user",
                email: "test@user.com",
                givenName: "Calev",
                familyName: "Muzaffar"
            ),
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
                        data: ExerciseData(sets: 1, reps: 3, weight: 0, time: 0, distance: 0)
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
                        data: ExerciseData(sets: 4, reps: 3, weight: 0, time: 0, distance: 0)
                    )
                ],
                location: Location(latitude: 37.34727983131215, longitude: -121.88308869874288)
            )
        )
    }
}
#endif
