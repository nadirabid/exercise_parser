//
//  ViewExtensions.swift
//  client
//
//  Created by Nadir Muzaffar on 6/4/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
  func keyboardObserving() -> some View {
    self.modifier(KeyboardObserving())
  }
}
