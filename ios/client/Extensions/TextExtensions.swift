//
//  TextExtensions.swift
//  client
//
//  Created by Nadir Muzaffar on 5/19/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation
import SwiftUI

extension Text {
    func shouldItalicize(_ italicize: Bool) -> Text {
        if italicize {
            return self.italic()
        } else {
            return self
        }
    }
}
