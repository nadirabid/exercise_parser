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
    
    var abbreviatedMonthString: String {
        let f = DateFormatter()
        f.dateFormat = "LLL"
        return f.string(from: self)
    }
}
