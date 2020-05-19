//
//  DateExtensions.swift
//  client
//
//  Created by Nadir Muzaffar on 5/19/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation

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
    
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

