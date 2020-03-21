//
//  DateExtension.swift
//  client
//
//  Created by Nadir Muzaffar on 3/20/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation

extension Date {
    func getHumanFriendlyString() -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = "EEEE - MMM d, yyyy - h:mm a"
        return dateformat.string(from: self)
    }
}
