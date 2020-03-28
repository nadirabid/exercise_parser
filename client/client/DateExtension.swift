//
//  DateExtension.swift
//  client
//
//  Created by Nadir Muzaffar on 3/20/20.
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
}
