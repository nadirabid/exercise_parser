//
//  Utils.swift
//  client
//
//  Created by Nadir Muzaffar on 3/21/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

func secondsToElapsedTimeString(_ totalSeconds: Int) -> String {
    let seconds = totalSeconds % 60
    let minutes = totalSeconds / 60
    let hours = totalSeconds / (60*60)
    
    if hours == 0 && minutes == 0 {
        return "\(seconds)s"
    } else if hours == 0 {
        return "\(minutes)m \(seconds)s"
    } else {
        return "\(hours)h \(minutes)m"
    }
}

func dateToWorkoutName(_ d: Date) -> String {
    return "\(d.weekdayString.capitalized) \(d.timeOfDayString.lowercased()) workout"
}
