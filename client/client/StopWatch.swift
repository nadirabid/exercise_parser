import Foundation
import SwiftUI
import Combine

class Stopwatch: ObservableObject {
    @Published var counter: Int = 0
    
    var timer: Timer? = nil
    
    func start() {
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                self.counter += 1
            }
        }
    }
    
    func stop() {
        if self.timer == nil {
            return
        }
        
        timer!.invalidate()
        self.timer = nil
    }
    
    func reset() {
        counter = 0
        
        if self.timer == nil {
            return
        }
        
        timer!.invalidate()
    }
    
    func convertCountToTimeString() -> String {
        let seconds = counter % 60
        let minutes = counter / 60
        let hours = seconds / 60
        
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
