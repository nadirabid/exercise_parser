//
//  Utils.swift
//  client
//
//  Created by Nadir Muzaffar on 3/21/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation

func secondsToElapsedTimeString(_ seconds: Int) -> String {
    let seconds = seconds % 60
    let minutes = seconds / 60
    let hours = seconds / 60
    
    if hours == 0 {
        return "\(minutes)m \(seconds)s"
    }
    
    return "\(hours)h \(minutes)m"
}
