//
//  WorkoutTypeSelectorView.swift
//  client
//
//  Created by Nadir Muzaffar on 6/6/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

enum WorkoutType {
    case workout
    case routine
    case run
}

struct WorkoutTypeSelectorView: View {
    @State var workoutType: WorkoutType = .workout
    
    var body: some View {
        ZStack {
            if workoutType == .workout {
                ZStack {
                    WorkoutCreateView(disabled: true)
                        .blur(radius: 1.5)
                 
                    VStack(spacing: 0) {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            Text("00").font(.largeTitle)
                            Text("h").font(.title)
                            Text("00").font(.largeTitle)
                            Text("m").font(.title)
                            Text("00").font(.largeTitle)
                            Text("s").font(.title)
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                }
            } else if workoutType == .run {
                RunTrackerView()
            }
            
            WorkoutTypeSelectorButtonsView(workoutType: workoutType)
        }
    }
}

struct WorkoutTypeSelectorButtonsView: View {
    var workoutType: WorkoutType
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                Divider()
                
                HStack {
                    Spacer()
                    
                    RunningIconShape()
                        .frame(width: 50, height: 20)
                    
                    Spacer()
                    
                    DumbbellIconShape()
                        .fill(appColor)
                        .frame(width: 50, height: 20)
                    
                    Spacer()
                    
                    ClipboardIconShape()
                        .frame(width: 50, height: 20)
                    
                    Spacer()
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding([.bottom, .top])
                
                HStack {
                    Spacer()
                    
                    Button(action: {}) {
                        Text("START")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .padding()
                            .background(
                                Circle()
                                    .scaledToFill()
                                    .foregroundColor(appColor)
                            )
                    }
                    .padding([.bottom, .top])
                    
                    Spacer()
                }
            }
                .background(Color(UIColor.systemBackground))
        }
    }
}

struct WorkoutSelectorButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutTypeSelectorButtonsView().padding()
    }
}
