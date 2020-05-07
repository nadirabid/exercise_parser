//
//  IconViews.swift
//  client
//
//  Created by Nadir Muzaffar on 5/6/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

struct HomeIconView: Shape {
    let path: Path
    
    init() {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 280.37, y: 116.26))
        bezierPath.addLine(to: CGPoint(x: 96, y: 268.11))
        bezierPath.addLine(to: CGPoint(x: 96, y: 432))
        bezierPath.addLine(to: CGPoint(x: 96, y: 432))
        bezierPath.addCurve(to: CGPoint(x: 112, y: 448), controlPoint1: CGPoint(x: 96, y: 440.84), controlPoint2: CGPoint(x: 103.16, y: 448))
        bezierPath.addLine(to: CGPoint(x: 224.06, y: 447.71))
        bezierPath.addLine(to: CGPoint(x: 223.98, y: 447.71))
        bezierPath.addCurve(to: CGPoint(x: 239.98, y: 431.71), controlPoint1: CGPoint(x: 232.82, y: 447.71), controlPoint2: CGPoint(x: 239.98, y: 440.55))
        bezierPath.addLine(to: CGPoint(x: 239.98, y: 336))
        bezierPath.addLine(to: CGPoint(x: 239.98, y: 336))
        bezierPath.addCurve(to: CGPoint(x: 255.98, y: 320), controlPoint1: CGPoint(x: 239.98, y: 327.16), controlPoint2: CGPoint(x: 247.14, y: 320))
        bezierPath.addLine(to: CGPoint(x: 319.98, y: 320))
        bezierPath.addLine(to: CGPoint(x: 319.98, y: 320))
        bezierPath.addCurve(to: CGPoint(x: 335.98, y: 336), controlPoint1: CGPoint(x: 328.82, y: 320), controlPoint2: CGPoint(x: 335.98, y: 327.16))
        bezierPath.addLine(to: CGPoint(x: 335.98, y: 431.64))
        bezierPath.addLine(to: CGPoint(x: 335.98, y: 431.69))
        bezierPath.addCurve(to: CGPoint(x: 351.98, y: 447.69), controlPoint1: CGPoint(x: 335.98, y: 440.53), controlPoint2: CGPoint(x: 343.14, y: 447.69))
        bezierPath.addLine(to: CGPoint(x: 464, y: 448))
        bezierPath.addLine(to: CGPoint(x: 464, y: 448))
        bezierPath.addCurve(to: CGPoint(x: 480, y: 432), controlPoint1: CGPoint(x: 472.84, y: 448), controlPoint2: CGPoint(x: 480, y: 440.84))
        bezierPath.addLine(to: CGPoint(x: 480, y: 268))
        bezierPath.addLine(to: CGPoint(x: 295.67, y: 116.26))
        bezierPath.addLine(to: CGPoint(x: 295.69, y: 116.28))
        bezierPath.addCurve(to: CGPoint(x: 280.35, y: 116.28), controlPoint1: CGPoint(x: 291.22, y: 112.66), controlPoint2: CGPoint(x: 284.82, y: 112.66))
        bezierPath.addLine(to: CGPoint(x: 280.37, y: 116.26))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 571.6, y: 219.47))
        bezierPath.addLine(to: CGPoint(x: 488, y: 150.56))
        bezierPath.addLine(to: CGPoint(x: 488, y: 12.05))
        bezierPath.addLine(to: CGPoint(x: 488, y: 12.05))
        bezierPath.addCurve(to: CGPoint(x: 476, y: 0.05), controlPoint1: CGPoint(x: 488, y: 5.42), controlPoint2: CGPoint(x: 482.63, y: 0.05))
        bezierPath.addLine(to: CGPoint(x: 420, y: 0.05))
        bezierPath.addLine(to: CGPoint(x: 420, y: 0.05))
        bezierPath.addCurve(to: CGPoint(x: 408, y: 12.05), controlPoint1: CGPoint(x: 413.37, y: 0.05), controlPoint2: CGPoint(x: 408, y: 5.42))
        bezierPath.addLine(to: CGPoint(x: 408, y: 84.66))
        bezierPath.addLine(to: CGPoint(x: 318.47, y: 11))
        bezierPath.addLine(to: CGPoint(x: 318.18, y: 10.76))
        bezierPath.addCurve(to: CGPoint(x: 257.12, y: 11.29), controlPoint1: CGPoint(x: 300.32, y: -3.7), controlPoint2: CGPoint(x: 274.72, y: -3.48))
        bezierPath.addLine(to: CGPoint(x: 4.34, y: 219.47))
        bezierPath.addLine(to: CGPoint(x: 4.27, y: 219.53))
        bezierPath.addCurve(to: CGPoint(x: 2.79, y: 236.43), controlPoint1: CGPoint(x: -0.81, y: 223.79), controlPoint2: CGPoint(x: -1.47, y: 231.36))
        bezierPath.addLine(to: CGPoint(x: 28.24, y: 267.37))
        bezierPath.addLine(to: CGPoint(x: 28.18, y: 267.3))
        bezierPath.addCurve(to: CGPoint(x: 45.06, y: 269.07), controlPoint1: CGPoint(x: 32.35, y: 272.45), controlPoint2: CGPoint(x: 39.91, y: 273.24))
        bezierPath.addLine(to: CGPoint(x: 280.37, y: 75.26))
        bezierPath.addLine(to: CGPoint(x: 280.35, y: 75.28))
        bezierPath.addCurve(to: CGPoint(x: 295.69, y: 75.28), controlPoint1: CGPoint(x: 284.82, y: 71.66), controlPoint2: CGPoint(x: 291.22, y: 71.66))
        bezierPath.addLine(to: CGPoint(x: 530.9, y: 269))
        bezierPath.addLine(to: CGPoint(x: 530.84, y: 268.95))
        bezierPath.addCurve(to: CGPoint(x: 547.74, y: 267.47), controlPoint1: CGPoint(x: 535.91, y: 273.21), controlPoint2: CGPoint(x: 543.48, y: 272.55))
        bezierPath.addLine(to: CGPoint(x: 573.3, y: 236.4))
        bezierPath.addLine(to: CGPoint(x: 573.36, y: 236.33))
        bezierPath.addCurve(to: CGPoint(x: 571.58, y: 219.45), controlPoint1: CGPoint(x: 577.53, y: 231.18), controlPoint2: CGPoint(x: 576.73, y: 223.63))
        bezierPath.addLine(to: CGPoint(x: 571.6, y: 219.47))
        bezierPath.close()

        self.path = Path(bezierPath.cgPath)
    }
    
    func path(in rect: CGRect) -> Path {
        let bounds = self.path.boundingRect
        let scaleX = rect.size.width / bounds.width
        let scaleY = rect.size.height / bounds.height
        
        let factor = min(scaleX, max(scaleY, 0.0))
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        
        var transform  = CGAffineTransform.identity
        
        transform = transform.concatenating(CGAffineTransform(translationX: -center.x, y: -center.y))
        transform = transform.concatenating(CGAffineTransform(scaleX: factor, y: factor))
        transform = transform.concatenating(CGAffineTransform(translationX: rect.midX, y: rect.midY))
        
        return path.applying(transform)
    }
}

struct UserIconView: Shape {
    let path: Path
    
    init() {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 313.6, y: 304))
        bezierPath.addCurve(to: CGPoint(x: 224, y: 320), controlPoint1: CGPoint(x: 284.9, y: 304), controlPoint2: CGPoint(x: 271.1, y: 320))
        bezierPath.addCurve(to: CGPoint(x: 134.4, y: 304), controlPoint1: CGPoint(x: 176.9, y: 320), controlPoint2: CGPoint(x: 163.2, y: 304))
        bezierPath.addCurve(to: CGPoint(x: 0, y: 438.4), controlPoint1: CGPoint(x: 60.2, y: 304), controlPoint2: CGPoint(x: 0, y: 364.2))
        bezierPath.addLine(to: CGPoint(x: 0, y: 464))
        bezierPath.addCurve(to: CGPoint(x: 48, y: 512), controlPoint1: CGPoint(x: 0, y: 490.5), controlPoint2: CGPoint(x: 21.5, y: 512))
        bezierPath.addLine(to: CGPoint(x: 400, y: 512))
        bezierPath.addCurve(to: CGPoint(x: 448, y: 464), controlPoint1: CGPoint(x: 426.5, y: 512), controlPoint2: CGPoint(x: 448, y: 490.5))
        bezierPath.addLine(to: CGPoint(x: 448, y: 438.4))
        bezierPath.addCurve(to: CGPoint(x: 313.6, y: 304), controlPoint1: CGPoint(x: 448, y: 364.2), controlPoint2: CGPoint(x: 387.8, y: 304))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 400, y: 464))
        bezierPath.addLine(to: CGPoint(x: 48, y: 464))
        bezierPath.addLine(to: CGPoint(x: 48, y: 438.4))
        bezierPath.addCurve(to: CGPoint(x: 134.4, y: 352), controlPoint1: CGPoint(x: 48, y: 390.8), controlPoint2: CGPoint(x: 86.8, y: 352))
        bezierPath.addCurve(to: CGPoint(x: 224, y: 368), controlPoint1: CGPoint(x: 149, y: 352), controlPoint2: CGPoint(x: 172.7, y: 368))
        bezierPath.addCurve(to: CGPoint(x: 313.6, y: 352), controlPoint1: CGPoint(x: 275.7, y: 368), controlPoint2: CGPoint(x: 298.9, y: 352))
        bezierPath.addCurve(to: CGPoint(x: 400, y: 438.4), controlPoint1: CGPoint(x: 361.2, y: 352), controlPoint2: CGPoint(x: 400, y: 390.8))
        bezierPath.addLine(to: CGPoint(x: 400, y: 464))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 224, y: 288))
        bezierPath.addCurve(to: CGPoint(x: 368, y: 144), controlPoint1: CGPoint(x: 303.5, y: 288), controlPoint2: CGPoint(x: 368, y: 223.5))
        bezierPath.addCurve(to: CGPoint(x: 224, y: 0), controlPoint1: CGPoint(x: 368, y: 64.5), controlPoint2: CGPoint(x: 303.5, y: 0))
        bezierPath.addCurve(to: CGPoint(x: 80, y: 144), controlPoint1: CGPoint(x: 144.5, y: 0), controlPoint2: CGPoint(x: 80, y: 64.5))
        bezierPath.addCurve(to: CGPoint(x: 224, y: 288), controlPoint1: CGPoint(x: 80, y: 223.5), controlPoint2: CGPoint(x: 144.5, y: 288))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 224, y: 48))
        bezierPath.addCurve(to: CGPoint(x: 320, y: 144), controlPoint1: CGPoint(x: 276.9, y: 48), controlPoint2: CGPoint(x: 320, y: 91.1))
        bezierPath.addCurve(to: CGPoint(x: 224, y: 240), controlPoint1: CGPoint(x: 320, y: 196.9), controlPoint2: CGPoint(x: 276.9, y: 240))
        bezierPath.addCurve(to: CGPoint(x: 128, y: 144), controlPoint1: CGPoint(x: 171.1, y: 240), controlPoint2: CGPoint(x: 128, y: 196.9))
        bezierPath.addCurve(to: CGPoint(x: 224, y: 48), controlPoint1: CGPoint(x: 128, y: 91.1), controlPoint2: CGPoint(x: 171.1, y: 48))
        bezierPath.close()

        self.path = Path(bezierPath.cgPath)
    }
    
    func path(in rect: CGRect) -> Path {
        let bounds = self.path.boundingRect
        let scaleX = rect.size.width / bounds.width
        let scaleY = rect.size.height / bounds.height
        
        let factor = min(scaleX, max(scaleY, 0.0))
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        
        var transform  = CGAffineTransform.identity
        
        transform = transform.concatenating(CGAffineTransform(translationX: -center.x, y: -center.y))
        transform = transform.concatenating(CGAffineTransform(scaleX: factor, y: factor))
        transform = transform.concatenating(CGAffineTransform(translationX: rect.midX, y: rect.midY))
        
        return path.applying(transform)
    }
}
