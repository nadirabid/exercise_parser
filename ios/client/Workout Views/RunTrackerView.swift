//
//  RunTrackerView.swift
//  client
//
//  Created by Nadir Muzaffar on 6/7/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI
import MapKit

struct RunTrackerView: View {
    @EnvironmentObject var routeState: RouteState
    
    @State var isStopped: Bool = true
    
    var locationManager: RunTrackerLocationManager
    var stopwatch: Stopwatch = Stopwatch()
    
    init(disabled: Bool, locationManager _locationManager: RunTrackerLocationManager) {
        locationManager = _locationManager
        
        if !disabled {
            stopwatch.start()
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RunTrackerMapView(
                    trackUserPath: false,
                    locationManager: self.locationManager
                )
                
                VStack {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 0) {
                        RunTrackerMetaMetricsView(stopwatch: self.stopwatch, isStopped: self.isStopped, width: geometry.size.width)
                        
                        if self.isStopped {
                            Divider()
                        }
                        
                        HStack {
                            Spacer()
                            
                            if !self.isStopped {
                                Button(action: {
                                    self.isStopped = true
                                }) {
                                    Image(systemName: "stop.circle")
                                        .font(.largeTitle)
                                        .foregroundColor(appColor)
                                }
                            } else {
                                Button(action: {
                                    self.routeState.replaceCurrent(with: .userFeed)
                                }) {
                                    Text("Save")
                                        .foregroundColor(Color.secondary)
                                        .animation(.none)
                                }
                                
                                Spacer()
                                Divider()
                                Spacer()
                                
                                Button(action: {
                                    self.isStopped = false
                                    UIApplication.shared.endEditing()
                                }) {
                                    Text("Resume")
                                        .foregroundColor(Color.secondary)
                                        .animation(.none)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    .background(Color(UIColor.systemBackground))
                }
                .keyboardObserving()
            }
            .edgesIgnoringSafeArea(.top)
        }
    }
}

// extension for keyboard to dismiss
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

public struct RunTrackerMetaMetricsView: View {
    @ObservedObject var stopwatch: Stopwatch
    @State var runName: String = ""
    
    var isStopped: Bool = false
    var width: CGFloat = 0
    
    var totalDistance: Float {
        return 0
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            if !self.isStopped {
                HStack(spacing: 0) {
                    WorkoutDetail(
                        name: "Time",
                        value: secondsToElapsedTimeString(self.stopwatch.counter)
                    )
                        .padding([.leading, .trailing])
                        .frame(width: self.width / 2, alignment: .center)
                    
                    Divider()
                    
                    WorkoutDetail(
                        name: "Distance",
                        value: "\(self.totalDistance) mi"
                    )
                        .padding([.leading, .trailing])
                        .frame(width: self.width / 2, alignment: .center)
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top)
            } else {
                Text("Workout name")
                    .font(.caption)
                    .padding([.leading, .top])
                    .padding(.bottom, 3)
                    .foregroundColor(Color.gray)
                
                TextField("Wednesday workout", text: self.$runName)
                    .padding([.leading, .trailing])
                    .padding([.top, .bottom], 12)
                    .background(Color(#colorLiteral(red: 0.9813412119, green: 0.9813412119, blue: 0.9813412119, alpha: 1)))
                    .border(Color(#colorLiteral(red: 0.9160850254, green: 0.9160850254, blue: 0.9160850254, alpha: 1)))
                    .introspectTextField { (textField: UITextField) in
                        textField.becomeFirstResponder()
                    }
                
                VStack {
                    HStack(spacing: 0) {
                        VStack(alignment: .center) {
                            Text("Time").foregroundColor(Color.secondary)
                            Text("5m 20s").font(.title).allowsTightening(false).fixedSize()
                        }
                        .padding([.leading, .trailing])
                        .frame(width: self.width / 2, alignment: .center)
                        
                        Divider()
                        
                        VStack(alignment: .center) {
                            Text("Calories").foregroundColor(Color.secondary)
                            Text("238").font(.title)
                        }
                        .padding([.leading, .trailing])
                        .frame(width: self.width / 2, alignment: .center)
                    }
                    .fixedSize()
                    
                    HStack(spacing: 0) {
                        VStack(alignment: .center) {
                            Text("Distance").foregroundColor(Color.secondary)
                            Text("3.2 mi").font(.title)
                        }
                        .padding([.leading, .trailing])
                        .frame(width: self.width / 2, alignment: .center)
                        
                        Divider()
                        
                        VStack(alignment: .center) {
                            Text("Pace").foregroundColor(Color.secondary)
                            Text("4:37 / mi").font(.title)
                        }
                        .padding([.leading, .trailing])
                        .frame(width: self.width / 2, alignment: .center)
                    }
                    .fixedSize()
                }
                .padding([.top, .bottom])
            }
        }
    }
}

struct RunTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        RunTrackerView(disabled: true, locationManager: RunTrackerLocationManager())
    }
}
