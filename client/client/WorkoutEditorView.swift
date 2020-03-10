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

// TODO: fix scroll bug due to auto focus
// TODO: fix the workout timer counting to 100 instead of 60
// TODO: add on text change - re resolve the exercise w/ some debounce

class UserActivity {
    var id = UUID()
    @State var input: String
    var dataTaskPublisher: AnyCancellable?
    var exercise: Exercise?
    
    init(input: String) {
        self.input = input
    }
    
    init(input: String, dataTaskPublisher: AnyCancellable?, exercise: Exercise?) {
        self.input = input
        self.dataTaskPublisher = dataTaskPublisher
        self.exercise = exercise
    }
}

public struct WorkoutEditorView: View {
    @EnvironmentObject var route: RouteState
    @EnvironmentObject var state: WorkoutEditorState
    @ObservedObject private var stopWatch: Stopwatch = Stopwatch();
    @State private var workoutDataTaskPublisher: AnyCancellable? = nil
    
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
        let exercises: [Exercise] = state.activities.map{ a in Exercise(raw: a.input) }
        let workout = Workout(name: state.workoutName, exercises: exercises)
        
        let jsonData = try! JSONEncoder().encode(workout)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
        }
        
        var request = URLRequest(url: URL(string: "\(baseURL)/workout")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.httpMethod = "POST"
        
        state.dataTaskPublisher = URLSession
            .shared
            .dataTaskPublisher(for: request)
            .map{ response in return response.data }
            .decode(type: Workout.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .replaceError(with: Workout())
            .sink(receiveValue: { _ in
                self.state.reset()
                self.route.current = .feed
            })
    }
    
    func resolveRawExercise(userActivity: UserActivity) {
        // we do this just for viewing purposes
        let exercise = Exercise(raw: userActivity.input)
        
        let jsonData = try! JSONEncoder().encode(exercise)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
        }
        
        var request = URLRequest(url: URL(string: "\(baseURL)/exercise/resolve")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.httpMethod = "POST"
        
        userActivity.dataTaskPublisher = URLSession
            .shared
            .dataTaskPublisher(for: request)
            .map{ response in response.data }
            .decode(type: Exercise.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .replaceError(with: Exercise())
            .sink(receiveValue: { response in userActivity.exercise = response })
    }
    
    public var body: some View {
        var textFieldCtx: UITextField? = nil
        let appColor: Color = Color(red: 224 / 255, green: 84 / 255, blue: 9 / 255)

        return VStack(alignment: .leading) {
            HStack {
                Spacer()
                
                Text(self.stopWatch.convertCountToTimeString())
                    .font(.title)
                
                Spacer()
            }
            
            ScrollView {
                ForEach(state.activities, id: \.id) { activity in
                    VStack {
                        TextField("New entry", text: activity.$input, onCommit: {
                            textFieldCtx!.becomeFirstResponder()
                        })
                        .font(.body)
                        
                        if activity.exercise != nil {
                            ActivityView(
                                exercise: activity.exercise!,
                                asSecondary: true
                            )
                        }
                        
                        Divider()
                    }
                }
                
                TextField("New entry", text: $state.newEntry, onCommit: {
                    if !self.state.newEntry.isEmpty {
                        let userActivity = UserActivity(input: self.state.newEntry)
                        self.state.activities.append(userActivity)
                        self.resolveRawExercise(userActivity: userActivity)
                        
                        self.state.newEntry = ""
                        textFieldCtx?.becomeFirstResponder()
                    }
                })
                .introspectTextField { textField in
                    textField.becomeFirstResponder()
                    textFieldCtx = textField
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
        WorkoutEditorView()
            .padding([.leading, .trailing, .bottom])
            .edgesIgnoringSafeArea(.bottom)
            .environmentObject(WorkoutEditorState())
            .environmentObject(RouteState(current: .editor))
    }
}
#endif
