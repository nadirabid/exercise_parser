//
//  WorkoutEditorView.swift
//  client
//
//  Created by Nadir Muzaffar on 10/12/19.
//  Copyright © 2019 Nadir Muzaffar. All rights reserved.
//

import SwiftUI
import Introspect

// TODO: fix scroll bug due to auto focus
// TODO; fix timer counting to 100 instead of 60

struct WorkoutEditorView : View {
    @State private var amount: Decimal?
    @State private var date: Date?

    public var body: some View {
        ActivityField()
    }
}

struct UserActivity {
    var id = UUID()
    @State var input: String
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
    
    var workouts: [ActivityViewModel] = [
        ActivityViewModel(name: "Running", units: [["mi", "0.7"]]),
        ActivityViewModel(name: "Rowing", units: [["m", "700"], ["mins", "4"]]),
        ActivityViewModel(name: "Incline Benchpress", units: [["sets", "5"], ["reps", "5"], ["lbs", "95"]]),
        ActivityViewModel(name: "Situps", units: [["reps", "60"]]),
        ActivityViewModel(name: "Deadlift", units: [["sets", "5"], ["reps", "5"], ["lbs", "188"]])
    ]
    
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
                        
                        ActivityView(
                            exercise: Exercise(id: 0, createdAt: "", updatedAt: "", name: "", type: "", raw: "", weightedExercise: nil, distanceExercise: nil),
                            workout: self.workouts[2],
                            asSecondary: true
                        )
                        
                        Divider()
                    }
                }
                
                TextField("New entry", text: $newEntry, onCommit: {
                    if !self.newEntry.isEmpty {
                        self.activities.append(UserActivity(input: self.newEntry))
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
