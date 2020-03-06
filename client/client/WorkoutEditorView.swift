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

struct WorkoutEditorView : View {
    @State private var amount: Decimal?
    @State private var date: Date?

    public var body: some View {
        ActivityField()
    }
}

class UserActivity: ObservableObject {
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

public struct ActivityField: View {
    @State private var workoutName: String = "Morning workout"
    @State private var newEntry: String = ""
    @State private var activities: [UserActivity] = [
        UserActivity(input: "running for 5 minutes"),
        UserActivity(input: "running for 5 minutes"),
        UserActivity(input: "3x3 tricep curls at 45lbs")
    ]
    @State private var isStopped = false
    
    @ObservedObject private var stopWatch: Stopwatch = Stopwatch();
    
    init() {
        stopWatch.start()
    }
    
    func pressStop() {
        self.stopWatch.stop()
        self.isStopped = true
    }
    
    func pressResume() {
        self.stopWatch.start()
        self.isStopped = false
    }
    
    func pressFinish() {
        pressStop()
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
                ForEach(activities, id: \.id) { activity in
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
                
                TextField("New entry", text: $newEntry, onCommit: {
                    if !self.newEntry.isEmpty {
                        let userActivity = UserActivity(input: self.newEntry)
                        self.activities.append(userActivity)
                        self.resolveRawExercise(userActivity: userActivity)
                        
                        self.newEntry = ""
                        textFieldCtx!.becomeFirstResponder()
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
                
                if !isStopped {
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
        .padding()
        .edgesIgnoringSafeArea(.bottom)
    }
}

#if DEBUG
struct WorkoutEditorView_Previews : PreviewProvider {
    static var previews: some View {
        WorkoutEditorView()
    }
}
#endif
