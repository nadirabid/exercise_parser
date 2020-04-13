//
//  Extensions.swift
//  client
//
//  Created by Nadir Muzaffar on 4/9/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

extension String: Error {}

extension Float32 {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

extension Text {
    func shouldItalicize(_ italicize: Bool) -> Text {
        if italicize {
            return self.italic()
        } else {
            return self
        }
    }
}

extension Color {
    init(_ hex: UInt32, opacity:Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

extension Date {
    var monthDayYearString: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f.string(from: self)
    }
    
    var yearString: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy"
        return f.string(from: self)
    }
    
    var dayString: String {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f.string(from: self)
    }
    
    var weekdayString: String {
        let weekday = Calendar.current.component(.weekday, from: self) - 1
        let f = DateFormatter()
        return f.weekdaySymbols[weekday]
    }
    
    var abbreviatedMonthString: String {
        let f = DateFormatter()
        f.dateFormat = "LLL"
        return f.string(from: self)
    }
    
    var timeOfDayString: String {
        //TODO: localize?
        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {
        case 6..<12 : return NSLocalizedString("Morning", comment: "Morning")
        case 12 : return NSLocalizedString("Noon", comment: "Noon")
        case 13..<17 : return NSLocalizedString("Afternoon", comment: "Afternoon")
        case 17..<22 : return NSLocalizedString("Evening", comment: "Evening")
        default: return NSLocalizedString("Night", comment: "Night")
        }
    }
}
