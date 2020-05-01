//
//  Extensions.swift
//  client
//
//  Created by Nadir Muzaffar on 4/9/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import UIKit
import SwiftUI

extension String: Error {}

extension Float32 {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

extension Text {
    func shouldItalicize(_ italicize: Bool) -> Text {
        if italicize {
            return self.italic()
        } else {
            return self
        }
    }
}

extension Color {
    init(_ hex: UInt32, opacity:Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

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

extension CGRect {
    var center: CGPoint {
        return CGPoint( x: self.size.width/2.0,y: self.size.height/2.0)
    }
}
extension CGPoint {
    func vector(to p1:CGPoint) -> CGVector{
        return CGVector(dx: p1.x-self.x, dy: p1.y-self.y)
    }
}

extension UIBezierPath {
    func moveCenter(to:CGPoint) -> Self {
        let bound  = self.cgPath.boundingBox
        let center = bounds.center
        
        let zeroedTo = CGPoint(x: to.x-bound.origin.x, y: to.y-bound.origin.y)
        let vector = center.vector(to: zeroedTo)
        
        return offset(to: CGSize(width: vector.dx, height: vector.dy))
    }
    
    func offset(to offset:CGSize) -> Self {
        let t = CGAffineTransform(translationX: offset.width, y: offset.height)
        return applyCentered(transform: t)
    }
    
    func fit(into:CGRect) -> Self{
        let bounds = self.cgPath.boundingBox
        
        let sw     = into.size.width/bounds.width
        let sh     = into.size.height/bounds.height
        let factor = min(sw, max(sh, 0.0))
        
        return scale(x: factor, y: factor)
    }
    
    func scale(x:CGFloat, y:CGFloat) -> Self{
        let scale = CGAffineTransform(scaleX: x, y: y)
        return applyCentered(transform: scale)
    }
    
    
    func applyCentered(transform: @autoclosure () -> CGAffineTransform ) -> Self {
        let bound  = self.cgPath.boundingBox
        let center = CGPoint(x: bound.midX, y: bound.midY)
        var xform  = CGAffineTransform.identity
        
        xform = xform.concatenating(CGAffineTransform(translationX: -center.x, y: -center.y))
        xform = xform.concatenating(transform())
        xform = xform.concatenating( CGAffineTransform(translationX: center.x, y: center.y))
        apply(xform)
        
        return self
    }
}
