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
                .allowsTightening(true)
                .fixedSize()
                .animation(.none)
        }
    }
}

struct WorkoutView: View {
    @EnvironmentObject var userAPI: UserAPI
    @EnvironmentObject var routeState: RouteState
    
    var user: User? = nil
    var workout: Workout
    var showUserInfo: Bool = true
    var showUnresolved: Bool = true
    var onDelete: () -> Void = {}
    
    var options = [ "waveform.path.ecg", "function" ]
    
    @State private var userImage: Image? = nil
    @State private var view = "waveform.path.ecg"
    @State private var showingActionSheet = false
    
    func shouldShowRoundsBeforeExercise(_ exercise: Exercise) -> Bool {
        let firstExerciseOfCircuitID = exercisesToDisplay.first(where: { $0.circuitID == exercise.circuitID })
        if exercise.circuitID != nil && firstExerciseOfCircuitID != nil && exercise.id == firstExerciseOfCircuitID!.id {
            return true
        }
        
        return false
    }
    
    var exercisesToDisplay: [Exercise] {
        if showUnresolved {
            return workout.exercises.sorted(by: {
                if $0.id != nil && $1.id != nil {
                    return $0.id! < $1.id!
                } else if $0.circuitID == nil && $1.circuitID != nil {
                    return false
                } else if $0.circuitID != nil && $1.circuitID == nil {
                    return true
                } else if $0.circuitID != nil && $1.circuitID != nil {
                    return $0.circuitID! > $1.circuitID!
                } else if $0.type != $1.type {
                    return $0.type > $1.type
                } else if $0.resolutionType != $0.resolutionType {
                    return $0.type > $1.type
                } else {
                    return $0.name < $1.name
                }
            })
        } else {
            return workout.exercises.filter({ $0.type != "" && !$0.resolutionType.contains("failed") })
        }
    }
    
    var body: some View {
        if self.showUserInfo &&
            self.user != nil &&
            self.user!.imageExists != nil &&
            self.user!.imageExists! &&
            userImage == nil {
            self.userAPI.getImage(for: self.user!.id!).then { uiImage in
                self.userImage = Image(uiImage: uiImage)
            }
        }
        
        return VStack(alignment: .leading) {
            HStack {
                if showUserInfo {
                    if self.userImage != nil {
                        userImage!
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .frame(width: 45, height: 45)
                    } else {
                        VStack {
                            UserIconShape().fill(Color.gray).padding()
                        }
                        .background(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: 45, height: 45)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(workout.name)
                        
                        Text(user?.getUserName() ?? "")
                            .font(.caption)
                            .foregroundColor(Color.gray)
                    }
                } else {
                    HStack {
                        Text(workout.name)
                        
                        Spacer()
                        
                        Button(action: { self.showingActionSheet = true }) {
                            Image(systemName:"ellipsis")
                                .background(Color.white)
                                .font(.headline)
                                .foregroundColor(Color.secondary)
                        }
                        .padding(.trailing)
                    }
                }
            }
            .padding(.leading)
            
            WorkoutMetaMetricsView(workout: workout)
                .fixedSize(horizontal: true, vertical: true)
                .padding(.leading)
            
            if view == "waveform.path.ecg" {
                if self.workout.location != nil {
                    WorkoutMapView(location: self.workout.location!)
                        .frame(height: CGFloat(130.0))
                }
                
                VStack(spacing: 0) {
                    ForEach(exercisesToDisplay) { (exercise: Exercise) in
                        VStack(spacing: 0) {
                            if self.shouldShowRoundsBeforeExercise(exercise) {
                                CircuitRoundsButtonView(circuitRounds: exercise.circuitRounds, isActive: false)
                                    .padding(.leading, -2)
                                    .padding(.bottom, 3)
                            }
                            
                            if exercise.type != "" {
                                ExerciseView(exercise: exercise)
                                    .padding(.leading, exercise.circuitID == nil ? 0 : nil)
                                    .padding(.bottom, 3)
                            } else if exercise.correctiveCode > 0 {
                                CorrectiveExerciseView(exercise: exercise)
                                    .padding(.leading, exercise.circuitID == nil ? 0 : nil)
                                    .padding(.bottom, 3)
                            } else {
                                ProcessingExerciseView(exercise: exercise)
                                    .padding(.leading, exercise.circuitID == nil ? 0 : nil)
                                    .padding(.bottom, 3)
                            }
                        }
                    }
                }
                .padding([.leading, .trailing])
            } else {
                WorkoutMuscleMetricsView(workout: self.workout)
            }
            
            HStack {
                Spacer()
                
                Picker(selection: self.$view, label: Text("Time range")) {
                    ForEach(options, id: \.self) { o in
                        VStack {
                            Image(systemName: o)
                                .font(.caption)
                                .tag(o)
                        }
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .fixedSize()
                
                Spacer()
            }
        }
        .padding([.top, .bottom])
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(title: Text(workout.name), buttons: [
                .default(Text("Edit")) { self.routeState.editWorkout = self.workout },
                .destructive(Text("Delete")) { self.onDelete() },
                .cancel()
            ])
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

    var targetMuscles: [MuscleActivation] {
        if dictionaries == nil {
            return []
        }
        
        return self.dictionaries!.flatMap { (dictionary) -> [MuscleActivation] in
            let muscleStrings = dictionary.muscles.target?.map { s in s.lowercased() } ?? []
            
            return muscleStrings.flatMap { (muscleString) -> [MuscleActivation] in
                if let muscle = Muscle.from(name: muscleString) {
                    if muscle.isMuscleGroup {
                        return muscle.components.map { MuscleActivation(muscle: $0) }
                    } else {
                        return [MuscleActivation(muscle: muscle)]
                    }
                }
                
                return []
            }
        }
    }
    
    var synergistMuscles: [MuscleActivation] {
        if dictionaries == nil {
            return []
        }
        
        return self.dictionaries!.flatMap { (dictionary) -> [MuscleActivation] in
            let muscleStrings = dictionary.muscles.synergists?.map { s in s.lowercased() } ?? []
            
            return muscleStrings.flatMap { (muscleString) -> [MuscleActivation] in
                if let muscle = Muscle.from(name: muscleString) {
                    if muscle.isMuscleGroup {
                        return muscle.components.map { MuscleActivation(muscle: $0) }
                    } else {
                        return [MuscleActivation(muscle: muscle)]
                    }
                }
                
                return []
            }
        }
    }
    
    var dynamicArticulationMuscles: [MuscleActivation] {
        if dictionaries == nil {
            return []
        }
        
        return self.dictionaries!.flatMap { (dictionary) -> [MuscleActivation] in
            let muscleStrings = dictionary.muscles.dynamicArticulation?.map { s in s.lowercased() } ?? []
            
            return muscleStrings.flatMap { (muscleString) -> [MuscleActivation] in
                if let muscle = Muscle.from(name: muscleString) {
                    if muscle.isMuscleGroup {
                        return muscle.components.map { MuscleActivation(muscle: $0) }
                    } else {
                        return [MuscleActivation(muscle: muscle)]
                    }
                }
                
                return []
            }
        }
    }
    
    var body: some View {
        return HStack(alignment: .center, spacing: 0) {
            AnteriorView(
                activatedTargetMuscles: self.targetMuscles,
                activatedSynergistMuscles: self.synergistMuscles,
                activatedDynamicArticulationMuscles: self.dynamicArticulationMuscles
            )
            
            PosteriorView(
                activatedTargetMuscles: self.targetMuscles,
                activatedSynergistMuscles: self.synergistMuscles,
                activatedDynamicArticulationMuscles: self.dynamicArticulationMuscles
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
            let circuitRounds = Float(e.circuitRounds > 1 ? e.circuitRounds : 1)
            let total =  e.data.displayWeightValue * Float(e.data.reps) * Float(e.data.sets) * circuitRounds
            return total + r
        }
        
        return Int(round(result))
    }
    
    var totalDistanceUnits: String {
        let result = workout.exercises.reduce(Float.zero) { (r, e) in
            let circuitRounds = Float(e.circuitRounds > 1 ? e.circuitRounds : 1)
            return r + e.data.distance * Float(circuitRounds)
        }
        
        if result <= 300 {
            return UnitLength.feet.symbol
        }
        
        return UnitLength.miles.symbol
    }
    
    var totalDistance: Float {
        let result = workout.exercises.reduce(Float.zero) { (r, e) in
            let circuitRounds = Float(e.circuitRounds > 1 ? e.circuitRounds : 1)
            return r + e.data.distance * circuitRounds
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
            if e.data.reps <= 1 {
                return r
            }
            
            let circuitRounds = e.circuitRounds > 1 ? e.circuitRounds : 1
            return r + e.data.reps * e.data.sets * circuitRounds
        }
        
        return result
    }
    
    var totalSets: Int {
        let result = workout.exercises.reduce(Int.zero) { (r, e) in
            if e.data.sets <= 1 {
                return r
            }
            
            let circuitRounds = e.circuitRounds > 1 ? e.circuitRounds : 1
            return r + e.data.sets * circuitRounds
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
            
            if totalSets > 1 {
                Divider()
                
                WorkoutDetail(name: "Sets", value:"\(totalSets.description)")
            }
            
            if totalReps > 1 {
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
                familyName: "Muzaffar",
                imageExists: nil,
                birthdate: nil,
                weight: 0,
                height: 0,
                isMale: true
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
                        type: "auto.single",
                        raw: "1x3 curls",
                        data: ExerciseData(sets: 1, reps: 3, weight: 0, time: 0, distance: 0)
                    ),
                    Exercise(
                        id: 2,
                        createdAt: "",
                        updatedAt: "",
                        type: "",
                        raw: "1x3 curls"
                    ),
                    Exercise(
                        raw: "3 reps",
                        correctiveCode: ExerciseCorrectiveCode.MissingExerciseAndReps.rawValue
                    ),
                    Exercise(
                        id: 3,
                        createdAt: "",
                        updatedAt: "",
                        name: "Benchpress",
                        type: "auto.single",
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
