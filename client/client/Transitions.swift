//
//  Transitions.swift
//  client
//
//  Created by Nadir Muzaffar on 3/29/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation
import SwiftUI

struct ScaleEffectHeightModifier: ViewModifier {
    let height: CGFloat

    init(_ height: CGFloat) {
        self.height = height
    }

    func body(content: Content) -> some View {
        content.scaleEffect(x: 1, y: height, anchor: UnitPoint.top)
    }
}

extension AnyTransition {
    static func scaleHeight(from: CGFloat, to: CGFloat) -> AnyTransition {
        .modifier(
            active: ScaleEffectHeightModifier(from),
            identity: ScaleEffectHeightModifier(to)
        )
    }
}
