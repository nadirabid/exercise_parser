//
//  FloatExtensions.swift
//  client
//
//  Created by Nadir Muzaffar on 5/19/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation

extension Float32 {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

