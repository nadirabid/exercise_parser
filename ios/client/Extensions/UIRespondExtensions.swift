//
//  UIRespondExtensions.swift
//  client
//
//  Created by Nadir Muzaffar on 6/4/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation
import UIKit

public extension UIResponder {
    private struct Static {
        static weak var responder: UIResponder?
    }

    static func currentFirst() -> UIResponder? {
        Static.responder = nil
        UIApplication.shared.sendAction(#selector(UIResponder._trap), to: nil, from: nil, for: nil)
        return Static.responder
    }

    @objc private func _trap() {
        Static.responder = self
    }
}

