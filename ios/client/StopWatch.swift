import Foundation
import SwiftUI
import Combine

extension Date {

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

}

class Stopwatch: ObservableObject {
    var date: Date? = nil
    var stopDate: Date? = nil
    var stopCounter: Int = 0
    @Published var counter: Int = 0
    @Published var seconds = 0
    @Published var minutes = 0
    @Published var hours = 0
    
    var timer: Timer? = nil
    
    var secondsString: String {
        var string = "\(seconds)"
        
        if seconds < 10 {
            string = "0" + string
        }
        
        return string
    }
    
    var minutesString: String {
        var string = "\(minutes)"
        
        if minutes < 10 {
            string = "0" + string
        }
        
        return string
    }
    
    var hoursString: String {
        var string = "\(hours)"
        
        if hours < 10 {
            string = "0" + string
        }
        
        return string
    }
    
    func start() {
        if date == nil {
            self.date = Date()
        }
        
        if stopDate != nil {
            let delta = Date() - self.stopDate!
            stopCounter = Int(round(delta))
        }
        
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                let delta = Date() - self.date!
                
                self.counter = Int(round(delta)) - self.stopCounter
                self.seconds = self.counter % 60
                self.minutes = (self.counter / 60) % 60
                self.hours = (self.counter / 60*60) % 60
            }
        }
    }
    
    func stop() {
        if self.timer == nil {
            return
        }
        
        
        timer!.invalidate()
        self.timer = nil
        self.stopDate = Date()
    }
    
    func reset() {
        counter = 0
        stopCounter = 0
        
        if self.timer == nil {
            return
        }
        
        timer!.invalidate()
    }
    
    func convertCountToTimeString() -> String {
        let seconds = counter % 60
        let minutes = (counter / 60) % 60
        let hours = (counter / 60*60) % 60
        
        var secondsString = "\(seconds)"
        var minutesString = "\(minutes)"
        var hoursString = "\(hours)"
        
        if seconds < 10 {
            secondsString = "0" + secondsString
        }
        
        if minutes < 10 {
            minutesString = "0" + minutesString
        }
        
        if hours < 10 {
            hoursString = "0" + hoursString
        }
        
        return "\(hoursString):\(minutesString):\(secondsString)"
    }
}
