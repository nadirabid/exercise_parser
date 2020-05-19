//
//  BindingExtensions.swift
//  client
//
//  Created by Nadir Muzaffar on 5/19/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

extension Binding {
    func onChange(_ handler: @escaping (Value, Value) -> Void) -> Binding<Value> {
        return Binding(
            get: {
                self.wrappedValue
            },
            set: { selection in
                let old = self.wrappedValue
                self.wrappedValue = selection
                handler(selection, old)
            }
        )
    }
}
