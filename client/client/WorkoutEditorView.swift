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

// TODO: fix scroll bug due to auto focus
// TODO: fix the workout timer counting to 100 instead of 60
// TODO: add on text change - re resolve the exercise w/ some debounce

public struct WorkoutEditorView: View {
    @EnvironmentObject var userState: UserState
    @EnvironmentObject var route: RouteState
    @EnvironmentObject var state: WorkoutEditorState
    @ObservedObject private var stopWatch: Stopwatch = Stopwatch();
    @State private var workoutDataTaskPublisher: AnyCancellable? = nil
    @State private var textFieldContext: UITextField? = nil
    
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
        
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Authorization": "Bearer \(userState.jwt!.string)"
        ]
        
        AF.request("\(baseURL)/workout", method: .post, parameters: workout, encoder: JSONParameterEncoder.default, headers: headers)
            .validate(statusCode: 200..<300)
            .response(queue: DispatchQueue.main) { (response) in
                self.state.reset()
                self.route.current = .feed
            }
    }
    
    func resolveRawExercise(userActivity: UserActivity) {
        // we do this just for viewing purposes
        let exercise = Exercise(raw: userActivity.input)
        
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Authorization": "Bearer \(userState.jwt!.string)"
        ]
        
        AF.request("\(baseURL)/exercise/resolve", method: .post, parameters: exercise, encoder: JSONParameterEncoder.default, headers: headers)
            .validate(statusCode: 200..<300)
            .response(queue: DispatchQueue.main) { (response) in
                switch response.result {
                case .success(let data):
                    let e = try! JSONDecoder().decode(Exercise.self, from: data!)
                    userActivity.exercise = e
                case .failure(let error):
                    print("Failed to resolve exercise: ", error)
                }
            }
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                
                Text(self.stopWatch.convertCountToTimeString())
                    .font(.title)
                
                Spacer()
            }
            
            ScrollView {
                ForEach(state.activities, id: \.id) { activity in
                    ExerciseEditorView(activity: activity, textFieldContext: self.textFieldContext)
                }
                
                TextField("New entry", text: $state.newEntry, onCommit: {
                    self.state.newEntry = self.state.newEntry.trimmingCharacters(in: .whitespaces)
                    
                    if !self.state.newEntry.isEmpty {
                        let userActivity = UserActivity(input: self.state.newEntry)
                        self.state.activities.append(userActivity)
                        self.resolveRawExercise(userActivity: userActivity)
                        
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

public struct ExerciseEditorView: View {
    @ObservedObject var activity: UserActivity
    var textFieldContext: UITextField?
    
    public var body: some View {
        VStack {
            TextField("", text: $activity.input, onCommit: {
                self.textFieldContext!.becomeFirstResponder()
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
}

#if DEBUG
struct WorkoutEditorView_Previews : PreviewProvider {
    static var previews: some View {
        WorkoutEditorView()
            .padding([.leading, .trailing, .bottom])
            .edgesIgnoringSafeArea(.bottom)
            .environmentObject(WorkoutEditorState())
            .environmentObject(RouteState(current: .editor))
            .environmentObject(UserState())
    }
}
#endif
