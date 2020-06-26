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

struct HomeIconShape: Shape {
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

struct UserIconShape: Shape {
    let path: Path
    
    init() {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 256, y: 288))
        bezierPath.addCurve(to: CGPoint(x: 400, y: 144), controlPoint1: CGPoint(x: 335.5, y: 288), controlPoint2: CGPoint(x: 400, y: 223.5))
        bezierPath.addCurve(to: CGPoint(x: 256, y: 0), controlPoint1: CGPoint(x: 400, y: 64.5), controlPoint2: CGPoint(x: 335.5, y: 0))
        bezierPath.addCurve(to: CGPoint(x: 112, y: 144), controlPoint1: CGPoint(x: 176.5, y: 0), controlPoint2: CGPoint(x: 112, y: 64.5))
        bezierPath.addCurve(to: CGPoint(x: 256, y: 288), controlPoint1: CGPoint(x: 112, y: 223.5), controlPoint2: CGPoint(x: 176.5, y: 288))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 384, y: 320))
        bezierPath.addLine(to: CGPoint(x: 328.9, y: 320))
        bezierPath.addCurve(to: CGPoint(x: 256, y: 336), controlPoint1: CGPoint(x: 306.7, y: 330.2), controlPoint2: CGPoint(x: 282, y: 336))
        bezierPath.addCurve(to: CGPoint(x: 183.1, y: 320), controlPoint1: CGPoint(x: 230, y: 336), controlPoint2: CGPoint(x: 205.4, y: 330.2))
        bezierPath.addLine(to: CGPoint(x: 128, y: 320))
        bezierPath.addCurve(to: CGPoint(x: 0, y: 448), controlPoint1: CGPoint(x: 57.3, y: 320), controlPoint2: CGPoint(x: 0, y: 377.3))
        bezierPath.addLine(to: CGPoint(x: 0, y: 464))
        bezierPath.addCurve(to: CGPoint(x: 48, y: 512), controlPoint1: CGPoint(x: 0, y: 490.5), controlPoint2: CGPoint(x: 21.5, y: 512))
        bezierPath.addLine(to: CGPoint(x: 464, y: 512))
        bezierPath.addCurve(to: CGPoint(x: 512, y: 464), controlPoint1: CGPoint(x: 490.5, y: 512), controlPoint2: CGPoint(x: 512, y: 490.5))
        bezierPath.addLine(to: CGPoint(x: 512, y: 448))
        bezierPath.addCurve(to: CGPoint(x: 384, y: 320), controlPoint1: CGPoint(x: 512, y: 377.3), controlPoint2: CGPoint(x: 454.7, y: 320))
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

struct HollowUserIconShape: Shape {
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

struct UserFriendsShape: Shape {
    let path: Path
    
    init() {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 192, y: 224))
        bezierPath.addCurve(to: CGPoint(x: 304, y: 112), controlPoint1: CGPoint(x: 253.9, y: 224), controlPoint2: CGPoint(x: 304, y: 173.9))
        bezierPath.addCurve(to: CGPoint(x: 192, y: 0), controlPoint1: CGPoint(x: 304, y: 50.1), controlPoint2: CGPoint(x: 253.9, y: 0))
        bezierPath.addCurve(to: CGPoint(x: 80, y: 112), controlPoint1: CGPoint(x: 130.1, y: 0), controlPoint2: CGPoint(x: 80, y: 50.1))
        bezierPath.addCurve(to: CGPoint(x: 192, y: 224), controlPoint1: CGPoint(x: 80, y: 173.9), controlPoint2: CGPoint(x: 130.1, y: 224))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 268.8, y: 256))
        bezierPath.addLine(to: CGPoint(x: 260.5, y: 256))
        bezierPath.addCurve(to: CGPoint(x: 192, y: 272), controlPoint1: CGPoint(x: 239.7, y: 266), controlPoint2: CGPoint(x: 216.6, y: 272))
        bezierPath.addCurve(to: CGPoint(x: 123.5, y: 256), controlPoint1: CGPoint(x: 167.4, y: 272), controlPoint2: CGPoint(x: 144.4, y: 266))
        bezierPath.addLine(to: CGPoint(x: 115.2, y: 256))
        bezierPath.addCurve(to: CGPoint(x: 0, y: 371.2), controlPoint1: CGPoint(x: 51.6, y: 256), controlPoint2: CGPoint(x: 0, y: 307.6))
        bezierPath.addLine(to: CGPoint(x: 0, y: 400))
        bezierPath.addCurve(to: CGPoint(x: 48, y: 448), controlPoint1: CGPoint(x: 0, y: 426.5), controlPoint2: CGPoint(x: 21.5, y: 448))
        bezierPath.addLine(to: CGPoint(x: 336, y: 448))
        bezierPath.addCurve(to: CGPoint(x: 384, y: 400), controlPoint1: CGPoint(x: 362.5, y: 448), controlPoint2: CGPoint(x: 384, y: 426.5))
        bezierPath.addLine(to: CGPoint(x: 384, y: 371.2))
        bezierPath.addCurve(to: CGPoint(x: 268.8, y: 256), controlPoint1: CGPoint(x: 384, y: 307.6), controlPoint2: CGPoint(x: 332.4, y: 256))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 480, y: 224))
        bezierPath.addCurve(to: CGPoint(x: 576, y: 128), controlPoint1: CGPoint(x: 533, y: 224), controlPoint2: CGPoint(x: 576, y: 181))
        bezierPath.addCurve(to: CGPoint(x: 480, y: 32), controlPoint1: CGPoint(x: 576, y: 75), controlPoint2: CGPoint(x: 533, y: 32))
        bezierPath.addCurve(to: CGPoint(x: 384, y: 128), controlPoint1: CGPoint(x: 427, y: 32), controlPoint2: CGPoint(x: 384, y: 75))
        bezierPath.addCurve(to: CGPoint(x: 480, y: 224), controlPoint1: CGPoint(x: 384, y: 181), controlPoint2: CGPoint(x: 427, y: 224))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 528, y: 256))
        bezierPath.addLine(to: CGPoint(x: 524.2, y: 256))
        bezierPath.addCurve(to: CGPoint(x: 480, y: 264), controlPoint1: CGPoint(x: 510.3, y: 260.8), controlPoint2: CGPoint(x: 495.6, y: 264))
        bezierPath.addCurve(to: CGPoint(x: 435.8, y: 256), controlPoint1: CGPoint(x: 464.4, y: 264), controlPoint2: CGPoint(x: 449.7, y: 260.8))
        bezierPath.addLine(to: CGPoint(x: 432, y: 256))
        bezierPath.addCurve(to: CGPoint(x: 376.3, y: 271.4), controlPoint1: CGPoint(x: 411.6, y: 256), controlPoint2: CGPoint(x: 392.8, y: 261.9))
        bezierPath.addCurve(to: CGPoint(x: 416, y: 371.2), controlPoint1: CGPoint(x: 400.7, y: 297.7), controlPoint2: CGPoint(x: 416, y: 332.6))
        bezierPath.addLine(to: CGPoint(x: 416, y: 409.6))
        bezierPath.addCurve(to: CGPoint(x: 415.4, y: 416), controlPoint1: CGPoint(x: 416, y: 411.8), controlPoint2: CGPoint(x: 415.5, y: 413.9))
        bezierPath.addLine(to: CGPoint(x: 592, y: 416))
        bezierPath.addCurve(to: CGPoint(x: 640, y: 368), controlPoint1: CGPoint(x: 618.5, y: 416), controlPoint2: CGPoint(x: 640, y: 394.5))
        bezierPath.addCurve(to: CGPoint(x: 528, y: 256), controlPoint1: CGPoint(x: 640, y: 306.1), controlPoint2: CGPoint(x: 589.9, y: 256))
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

struct ThinPeaksIconShape: Shape {
    let path: Path
    
    init() {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 442.4, y: 409.4))
        bezierPath.addLine(to: CGPoint(x: 529.5, y: 259.2))
        bezierPath.addLine(to: CGPoint(x: 497.5, y: 258.9))
        bezierPath.addLine(to: CGPoint(x: 442.4, y: 353.9))
        bezierPath.addLine(to: CGPoint(x: 236.2, y: 0))
        bezierPath.addLine(to: CGPoint(x: 0, y: 407.4))
        bezierPath.addLine(to: CGPoint(x: 32, y: 407.7))
        bezierPath.addLine(to: CGPoint(x: 236.2, y: 55.6))
        bezierPath.addLine(to: CGPoint(x: 442.4, y: 409.4))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 87.1, y: 365.3))
        bezierPath.addLine(to: CGPoint(x: 119.2, y: 365.3))
        bezierPath.addLine(to: CGPoint(x: 236.6, y: 162.8))
        bezierPath.addLine(to: CGPoint(x: 440, y: 511.9))
        bezierPath.addLine(to: CGPoint(x: 472.5, y: 512))
        bezierPath.addLine(to: CGPoint(x: 236.7, y: 107.4))
        bezierPath.addLine(to: CGPoint(x: 87.1, y: 365.3))
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

struct StreamIconShape: Shape {
    let path: Path
    
    init() {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 16, y: 96))
        bezierPath.addLine(to: CGPoint(x: 432, y: 96))
        bezierPath.addCurve(to: CGPoint(x: 448, y: 80), controlPoint1: CGPoint(x: 440.84, y: 96), controlPoint2: CGPoint(x: 448, y: 88.84))
        bezierPath.addLine(to: CGPoint(x: 448, y: 16))
        bezierPath.addCurve(to: CGPoint(x: 432, y: 0), controlPoint1: CGPoint(x: 448, y: 7.16), controlPoint2: CGPoint(x: 440.84, y: 0))
        bezierPath.addLine(to: CGPoint(x: 16, y: 0))
        bezierPath.addCurve(to: CGPoint(x: 0, y: 16), controlPoint1: CGPoint(x: 7.16, y: 0), controlPoint2: CGPoint(x: 0, y: 7.16))
        bezierPath.addLine(to: CGPoint(x: 0, y: 80))
        bezierPath.addCurve(to: CGPoint(x: 16, y: 96), controlPoint1: CGPoint(x: 0, y: 88.84), controlPoint2: CGPoint(x: 7.16, y: 96))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 496, y: 176))
        bezierPath.addLine(to: CGPoint(x: 80, y: 176))
        bezierPath.addCurve(to: CGPoint(x: 64, y: 192), controlPoint1: CGPoint(x: 71.16, y: 176), controlPoint2: CGPoint(x: 64, y: 183.16))
        bezierPath.addLine(to: CGPoint(x: 64, y: 256))
        bezierPath.addCurve(to: CGPoint(x: 80, y: 272), controlPoint1: CGPoint(x: 64, y: 264.84), controlPoint2: CGPoint(x: 71.16, y: 272))
        bezierPath.addLine(to: CGPoint(x: 496, y: 272))
        bezierPath.addCurve(to: CGPoint(x: 512, y: 256), controlPoint1: CGPoint(x: 504.84, y: 272), controlPoint2: CGPoint(x: 512, y: 264.84))
        bezierPath.addLine(to: CGPoint(x: 512, y: 192))
        bezierPath.addCurve(to: CGPoint(x: 496, y: 176), controlPoint1: CGPoint(x: 512, y: 183.16), controlPoint2: CGPoint(x: 504.84, y: 176))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 432, y: 352))
        bezierPath.addLine(to: CGPoint(x: 16, y: 352))
        bezierPath.addCurve(to: CGPoint(x: 0, y: 368), controlPoint1: CGPoint(x: 7.16, y: 352), controlPoint2: CGPoint(x: 0, y: 359.16))
        bezierPath.addLine(to: CGPoint(x: 0, y: 432))
        bezierPath.addCurve(to: CGPoint(x: 16, y: 448), controlPoint1: CGPoint(x: 0, y: 440.84), controlPoint2: CGPoint(x: 7.16, y: 448))
        bezierPath.addLine(to: CGPoint(x: 432, y: 448))
        bezierPath.addCurve(to: CGPoint(x: 448, y: 432), controlPoint1: CGPoint(x: 440.84, y: 448), controlPoint2: CGPoint(x: 448, y: 440.84))
        bezierPath.addLine(to: CGPoint(x: 448, y: 368))
        bezierPath.addCurve(to: CGPoint(x: 432, y: 352), controlPoint1: CGPoint(x: 448, y: 359.16), controlPoint2: CGPoint(x: 440.84, y: 352))
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

struct HeartIconShape: Shape {
    let path: Path
    
    init() {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 458.4, y: 32.3))
        bezierPath.addCurve(to: CGPoint(x: 256, y: 47.3), controlPoint1: CGPoint(x: 400.6, y: -16.3), controlPoint2: CGPoint(x: 311.3, y: -9))
        bezierPath.addCurve(to: CGPoint(x: 53.6, y: 32.3), controlPoint1: CGPoint(x: 200.7, y: -9), controlPoint2: CGPoint(x: 111.4, y: -16.4))
        bezierPath.addCurve(to: CGPoint(x: 43, y: 253.5), controlPoint1: CGPoint(x: -21.6, y: 95.6), controlPoint2: CGPoint(x: -10.6, y: 198.8))
        bezierPath.addLine(to: CGPoint(x: 218.4, y: 432.2))
        bezierPath.addCurve(to: CGPoint(x: 256, y: 448.1), controlPoint1: CGPoint(x: 228.4, y: 442.4), controlPoint2: CGPoint(x: 241.8, y: 448.1))
        bezierPath.addCurve(to: CGPoint(x: 293.6, y: 432.3), controlPoint1: CGPoint(x: 270.3, y: 448.1), controlPoint2: CGPoint(x: 283.6, y: 442.5))
        bezierPath.addLine(to: CGPoint(x: 469, y: 253.6))
        bezierPath.addCurve(to: CGPoint(x: 458.4, y: 32.3), controlPoint1: CGPoint(x: 522.5, y: 198.9), controlPoint2: CGPoint(x: 533.7, y: 95.7))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 434.8, y: 219.8))
        bezierPath.addLine(to: CGPoint(x: 259.4, y: 398.5))
        bezierPath.addCurve(to: CGPoint(x: 252.6, y: 398.5), controlPoint1: CGPoint(x: 257, y: 400.9), controlPoint2: CGPoint(x: 255, y: 400.9))
        bezierPath.addLine(to: CGPoint(x: 77.2, y: 219.8))
        bezierPath.addCurve(to: CGPoint(x: 84.5, y: 69.1), controlPoint1: CGPoint(x: 40.7, y: 182.6), controlPoint2: CGPoint(x: 33.3, y: 112.2))
        bezierPath.addCurve(to: CGPoint(x: 221, y: 79.6), controlPoint1: CGPoint(x: 123.4, y: 36.4), controlPoint2: CGPoint(x: 183.4, y: 41.3))
        bezierPath.addLine(to: CGPoint(x: 256, y: 115.3))
        bezierPath.addLine(to: CGPoint(x: 291, y: 79.6))
        bezierPath.addCurve(to: CGPoint(x: 427.5, y: 69), controlPoint1: CGPoint(x: 328.8, y: 41.1), controlPoint2: CGPoint(x: 388.8, y: 36.4))
        bezierPath.addCurve(to: CGPoint(x: 434.8, y: 219.8), controlPoint1: CGPoint(x: 478.6, y: 112.1), controlPoint2: CGPoint(x: 471, y: 182.9))
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

struct ChartIconShape: Shape {
    let path: Path
    
    init() {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 332.8, y: 256))
        bezierPath.addLine(to: CGPoint(x: 371.2, y: 256))
        bezierPath.addCurve(to: CGPoint(x: 384, y: 243.2), controlPoint1: CGPoint(x: 377.6, y: 256), controlPoint2: CGPoint(x: 384, y: 249.6))
        bezierPath.addLine(to: CGPoint(x: 384, y: 108.8))
        bezierPath.addCurve(to: CGPoint(x: 371.2, y: 96), controlPoint1: CGPoint(x: 384, y: 102.4), controlPoint2: CGPoint(x: 377.6, y: 96))
        bezierPath.addLine(to: CGPoint(x: 332.8, y: 96))
        bezierPath.addCurve(to: CGPoint(x: 320, y: 108.8), controlPoint1: CGPoint(x: 326.4, y: 96), controlPoint2: CGPoint(x: 320, y: 102.4))
        bezierPath.addLine(to: CGPoint(x: 320, y: 243.2))
        bezierPath.addCurve(to: CGPoint(x: 332.8, y: 256), controlPoint1: CGPoint(x: 320, y: 249.6), controlPoint2: CGPoint(x: 326.4, y: 256))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 428.8, y: 256))
        bezierPath.addLine(to: CGPoint(x: 467.2, y: 256))
        bezierPath.addCurve(to: CGPoint(x: 480, y: 243.2), controlPoint1: CGPoint(x: 473.6, y: 256), controlPoint2: CGPoint(x: 480, y: 249.6))
        bezierPath.addLine(to: CGPoint(x: 480, y: 12.8))
        bezierPath.addCurve(to: CGPoint(x: 467.2, y: 0), controlPoint1: CGPoint(x: 480, y: 6.4), controlPoint2: CGPoint(x: 473.6, y: 0))
        bezierPath.addLine(to: CGPoint(x: 428.8, y: 0))
        bezierPath.addCurve(to: CGPoint(x: 416, y: 12.8), controlPoint1: CGPoint(x: 422.4, y: 0), controlPoint2: CGPoint(x: 416, y: 6.4))
        bezierPath.addLine(to: CGPoint(x: 416, y: 243.2))
        bezierPath.addCurve(to: CGPoint(x: 428.8, y: 256), controlPoint1: CGPoint(x: 416, y: 249.6), controlPoint2: CGPoint(x: 422.4, y: 256))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 140.8, y: 256))
        bezierPath.addLine(to: CGPoint(x: 179.2, y: 256))
        bezierPath.addCurve(to: CGPoint(x: 192, y: 243.2), controlPoint1: CGPoint(x: 185.6, y: 256), controlPoint2: CGPoint(x: 192, y: 249.6))
        bezierPath.addLine(to: CGPoint(x: 192, y: 172.8))
        bezierPath.addCurve(to: CGPoint(x: 179.2, y: 160), controlPoint1: CGPoint(x: 192, y: 166.4), controlPoint2: CGPoint(x: 185.6, y: 160))
        bezierPath.addLine(to: CGPoint(x: 140.8, y: 160))
        bezierPath.addCurve(to: CGPoint(x: 128, y: 172.8), controlPoint1: CGPoint(x: 134.4, y: 160), controlPoint2: CGPoint(x: 128, y: 166.4))
        bezierPath.addLine(to: CGPoint(x: 128, y: 243.2))
        bezierPath.addCurve(to: CGPoint(x: 140.8, y: 256), controlPoint1: CGPoint(x: 128, y: 249.6), controlPoint2: CGPoint(x: 134.4, y: 256))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 236.8, y: 256))
        bezierPath.addLine(to: CGPoint(x: 275.2, y: 256))
        bezierPath.addCurve(to: CGPoint(x: 288, y: 243.2), controlPoint1: CGPoint(x: 281.6, y: 256), controlPoint2: CGPoint(x: 288, y: 249.6))
        bezierPath.addLine(to: CGPoint(x: 288, y: 44.8))
        bezierPath.addCurve(to: CGPoint(x: 275.2, y: 32), controlPoint1: CGPoint(x: 288, y: 38.4), controlPoint2: CGPoint(x: 281.6, y: 32))
        bezierPath.addLine(to: CGPoint(x: 236.8, y: 32))
        bezierPath.addCurve(to: CGPoint(x: 224, y: 44.8), controlPoint1: CGPoint(x: 230.4, y: 32), controlPoint2: CGPoint(x: 224, y: 38.4))
        bezierPath.addLine(to: CGPoint(x: 224, y: 243.2))
        bezierPath.addCurve(to: CGPoint(x: 236.8, y: 256), controlPoint1: CGPoint(x: 224, y: 249.6), controlPoint2: CGPoint(x: 230.4, y: 256))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 496, y: 320))
        bezierPath.addLine(to: CGPoint(x: 64, y: 320))
        bezierPath.addLine(to: CGPoint(x: 64, y: 16))
        bezierPath.addCurve(to: CGPoint(x: 48, y: 0), controlPoint1: CGPoint(x: 64, y: 7.16), controlPoint2: CGPoint(x: 56.84, y: 0))
        bezierPath.addLine(to: CGPoint(x: 16, y: 0))
        bezierPath.addCurve(to: CGPoint(x: 0, y: 16), controlPoint1: CGPoint(x: 7.16, y: 0), controlPoint2: CGPoint(x: 0, y: 7.16))
        bezierPath.addLine(to: CGPoint(x: 0, y: 352))
        bezierPath.addCurve(to: CGPoint(x: 32, y: 384), controlPoint1: CGPoint(x: 0, y: 369.67), controlPoint2: CGPoint(x: 14.33, y: 384))
        bezierPath.addLine(to: CGPoint(x: 496, y: 384))
        bezierPath.addCurve(to: CGPoint(x: 512, y: 368), controlPoint1: CGPoint(x: 504.84, y: 384), controlPoint2: CGPoint(x: 512, y: 376.84))
        bezierPath.addLine(to: CGPoint(x: 512, y: 336))
        bezierPath.addCurve(to: CGPoint(x: 496, y: 320), controlPoint1: CGPoint(x: 512, y: 327.16), controlPoint2: CGPoint(x: 504.84, y: 320))
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

struct QuestionIconShape: Shape {
    let path: Path
    
    init() {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 176.02, y: 0))
        bezierPath.addCurve(to: CGPoint(x: 3.91, y: 91.03), controlPoint1: CGPoint(x: 96.2, y: 0), controlPoint2: CGPoint(x: 44.5, y: 32.7))
        bezierPath.addCurve(to: CGPoint(x: 9.09, y: 123.9), controlPoint1: CGPoint(x: -3.45, y: 101.61), controlPoint2: CGPoint(x: -1.18, y: 116.11))
        bezierPath.addLine(to: CGPoint(x: 52.23, y: 156.61))
        bezierPath.addCurve(to: CGPoint(x: 85.48, y: 152.46), controlPoint1: CGPoint(x: 62.6, y: 164.47), controlPoint2: CGPoint(x: 77.36, y: 162.63))
        bezierPath.addCurve(to: CGPoint(x: 168.24, y: 103.01), controlPoint1: CGPoint(x: 110.53, y: 121.08), controlPoint2: CGPoint(x: 129.11, y: 103.01))
        bezierPath.addCurve(to: CGPoint(x: 237.06, y: 152.64), controlPoint1: CGPoint(x: 199, y: 103.01), controlPoint2: CGPoint(x: 237.06, y: 122.81))
        bezierPath.addCurve(to: CGPoint(x: 188.06, y: 203.81), controlPoint1: CGPoint(x: 237.06, y: 175.2), controlPoint2: CGPoint(x: 218.44, y: 186.78))
        bezierPath.addCurve(to: CGPoint(x: 105.76, y: 310.21), controlPoint1: CGPoint(x: 152.64, y: 223.67), controlPoint2: CGPoint(x: 105.76, y: 248.38))
        bezierPath.addLine(to: CGPoint(x: 105.76, y: 320))
        bezierPath.addCurve(to: CGPoint(x: 129.76, y: 344), controlPoint1: CGPoint(x: 105.76, y: 333.25), controlPoint2: CGPoint(x: 116.51, y: 344))
        bezierPath.addLine(to: CGPoint(x: 202.24, y: 344))
        bezierPath.addCurve(to: CGPoint(x: 226.24, y: 320), controlPoint1: CGPoint(x: 215.49, y: 344), controlPoint2: CGPoint(x: 226.24, y: 333.25))
        bezierPath.addLine(to: CGPoint(x: 226.24, y: 314.23))
        bezierPath.addCurve(to: CGPoint(x: 351.5, y: 153.6), controlPoint1: CGPoint(x: 226.24, y: 271.37), controlPoint2: CGPoint(x: 351.5, y: 269.58))
        bezierPath.addCurve(to: CGPoint(x: 176.02, y: 0), controlPoint1: CGPoint(x: 351.5, y: 66.26), controlPoint2: CGPoint(x: 260.9, y: 0))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 166, y: 373.46))
        bezierPath.addCurve(to: CGPoint(x: 96.73, y: 442.73), controlPoint1: CGPoint(x: 127.8, y: 373.46), controlPoint2: CGPoint(x: 96.73, y: 404.53))
        bezierPath.addCurve(to: CGPoint(x: 166, y: 512), controlPoint1: CGPoint(x: 96.73, y: 480.93), controlPoint2: CGPoint(x: 127.8, y: 512))
        bezierPath.addCurve(to: CGPoint(x: 235.27, y: 442.73), controlPoint1: CGPoint(x: 204.2, y: 512), controlPoint2: CGPoint(x: 235.27, y: 480.93))
        bezierPath.addCurve(to: CGPoint(x: 166, y: 373.46), controlPoint1: CGPoint(x: 235.27, y: 404.53), controlPoint2: CGPoint(x: 204.2, y: 373.46))
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

struct DumbbellIconShape: Shape {
    static let absoluteSize: CGSize = CGSize(width: 640, height: 512)
    
    func path(in rect: CGRect) -> Path {
        let scaleX = rect.size.width / DumbbellIconShape.absoluteSize.width
        let scaleY = rect.size.height / DumbbellIconShape.absoluteSize.height
        
        let factor = min(scaleX, max(scaleY, 0.0))
        let center = CGPoint(x: DumbbellIconShape.absoluteSize.width / 2, y: DumbbellIconShape.absoluteSize.height / 2)
        
        var transform  = CGAffineTransform.identity
        
        transform = transform.concatenating(CGAffineTransform(translationX: -center.x, y: -center.y))
        transform = transform.concatenating(CGAffineTransform(scaleX: factor, y: factor))
        transform = transform.concatenating(CGAffineTransform(translationX: rect.midX, y: rect.midY))
        
        let uiBezierPath = UIBezierPath()
        uiBezierPath.move(to: CGPoint(x: 104, y: 96))
        uiBezierPath.addLine(to: CGPoint(x: 56, y: 96))
        uiBezierPath.addCurve(to: CGPoint(x: 32, y: 120), controlPoint1: CGPoint(x: 42.7, y: 96), controlPoint2: CGPoint(x: 32, y: 106.7))
        uiBezierPath.addLine(to: CGPoint(x: 32, y: 224))
        uiBezierPath.addLine(to: CGPoint(x: 8, y: 224))
        uiBezierPath.addCurve(to: CGPoint(x: 0, y: 232), controlPoint1: CGPoint(x: 3.6, y: 224), controlPoint2: CGPoint(x: 0, y: 227.6))
        uiBezierPath.addLine(to: CGPoint(x: 0, y: 280))
        uiBezierPath.addCurve(to: CGPoint(x: 8, y: 288), controlPoint1: CGPoint(x: 0, y: 284.4), controlPoint2: CGPoint(x: 3.6, y: 288))
        uiBezierPath.addLine(to: CGPoint(x: 32, y: 288))
        uiBezierPath.addLine(to: CGPoint(x: 32, y: 392))
        uiBezierPath.addCurve(to: CGPoint(x: 56, y: 416), controlPoint1: CGPoint(x: 32, y: 405.3), controlPoint2: CGPoint(x: 42.7, y: 416))
        uiBezierPath.addLine(to: CGPoint(x: 104, y: 416))
        uiBezierPath.addCurve(to: CGPoint(x: 128, y: 392), controlPoint1: CGPoint(x: 117.3, y: 416), controlPoint2: CGPoint(x: 128, y: 405.3))
        uiBezierPath.addLine(to: CGPoint(x: 128, y: 120))
        uiBezierPath.addCurve(to: CGPoint(x: 104, y: 96), controlPoint1: CGPoint(x: 128, y: 106.7), controlPoint2: CGPoint(x: 117.3, y: 96))
        uiBezierPath.close()
        uiBezierPath.move(to: CGPoint(x: 632, y: 224))
        uiBezierPath.addLine(to: CGPoint(x: 608, y: 224))
        uiBezierPath.addLine(to: CGPoint(x: 608, y: 120))
        uiBezierPath.addCurve(to: CGPoint(x: 584, y: 96), controlPoint1: CGPoint(x: 608, y: 106.7), controlPoint2: CGPoint(x: 597.3, y: 96))
        uiBezierPath.addLine(to: CGPoint(x: 536, y: 96))
        uiBezierPath.addCurve(to: CGPoint(x: 512, y: 120), controlPoint1: CGPoint(x: 522.7, y: 96), controlPoint2: CGPoint(x: 512, y: 106.7))
        uiBezierPath.addLine(to: CGPoint(x: 512, y: 392))
        uiBezierPath.addCurve(to: CGPoint(x: 536, y: 416), controlPoint1: CGPoint(x: 512, y: 405.3), controlPoint2: CGPoint(x: 522.7, y: 416))
        uiBezierPath.addLine(to: CGPoint(x: 584, y: 416))
        uiBezierPath.addCurve(to: CGPoint(x: 608, y: 392), controlPoint1: CGPoint(x: 597.3, y: 416), controlPoint2: CGPoint(x: 608, y: 405.3))
        uiBezierPath.addLine(to: CGPoint(x: 608, y: 288))
        uiBezierPath.addLine(to: CGPoint(x: 632, y: 288))
        uiBezierPath.addCurve(to: CGPoint(x: 640, y: 280), controlPoint1: CGPoint(x: 636.4, y: 288), controlPoint2: CGPoint(x: 640, y: 284.4))
        uiBezierPath.addLine(to: CGPoint(x: 640, y: 232))
        uiBezierPath.addCurve(to: CGPoint(x: 632, y: 224), controlPoint1: CGPoint(x: 640, y: 227.6), controlPoint2: CGPoint(x: 636.4, y: 224))
        uiBezierPath.close()
        uiBezierPath.move(to: CGPoint(x: 456, y: 32))
        uiBezierPath.addLine(to: CGPoint(x: 408, y: 32))
        uiBezierPath.addCurve(to: CGPoint(x: 384, y: 56), controlPoint1: CGPoint(x: 394.7, y: 32), controlPoint2: CGPoint(x: 384, y: 42.7))
        uiBezierPath.addLine(to: CGPoint(x: 384, y: 224))
        uiBezierPath.addLine(to: CGPoint(x: 256, y: 224))
        uiBezierPath.addLine(to: CGPoint(x: 256, y: 56))
        uiBezierPath.addCurve(to: CGPoint(x: 232, y: 32), controlPoint1: CGPoint(x: 256, y: 42.7), controlPoint2: CGPoint(x: 245.3, y: 32))
        uiBezierPath.addLine(to: CGPoint(x: 184, y: 32))
        uiBezierPath.addCurve(to: CGPoint(x: 160, y: 56), controlPoint1: CGPoint(x: 170.7, y: 32), controlPoint2: CGPoint(x: 160, y: 42.7))
        uiBezierPath.addLine(to: CGPoint(x: 160, y: 456))
        uiBezierPath.addCurve(to: CGPoint(x: 184, y: 480), controlPoint1: CGPoint(x: 160, y: 469.3), controlPoint2: CGPoint(x: 170.7, y: 480))
        uiBezierPath.addLine(to: CGPoint(x: 232, y: 480))
        uiBezierPath.addCurve(to: CGPoint(x: 256, y: 456), controlPoint1: CGPoint(x: 245.3, y: 480), controlPoint2: CGPoint(x: 256, y: 469.3))
        uiBezierPath.addLine(to: CGPoint(x: 256, y: 288))
        uiBezierPath.addLine(to: CGPoint(x: 384, y: 288))
        uiBezierPath.addLine(to: CGPoint(x: 384, y: 456))
        uiBezierPath.addCurve(to: CGPoint(x: 408, y: 480), controlPoint1: CGPoint(x: 384, y: 469.3), controlPoint2: CGPoint(x: 394.7, y: 480))
        uiBezierPath.addLine(to: CGPoint(x: 456, y: 480))
        uiBezierPath.addCurve(to: CGPoint(x: 480, y: 456), controlPoint1: CGPoint(x: 469.3, y: 480), controlPoint2: CGPoint(x: 480, y: 469.3))
        uiBezierPath.addLine(to: CGPoint(x: 480, y: 56))
        uiBezierPath.addCurve(to: CGPoint(x: 456, y: 32), controlPoint1: CGPoint(x: 480, y: 42.7), controlPoint2: CGPoint(x: 469.3, y: 32))
        uiBezierPath.close()
        
        let path = Path(uiBezierPath.cgPath)
        return path.applying(transform)
    }
}

struct RunningIconShape: Shape {
    static let absoluteSize: CGSize = CGSize(width: 416, height: 512)

    func path(in rect: CGRect) -> Path {
        let scaleX = rect.size.width / RunningIconShape.absoluteSize.width
        let scaleY = rect.size.height / RunningIconShape.absoluteSize.height
        
        let factor = min(scaleX, max(scaleY, 0.0))
        let center = CGPoint(x: RunningIconShape.absoluteSize.width / 2, y: RunningIconShape.absoluteSize.height / 2)
        
        var transform  = CGAffineTransform.identity
        
        transform = transform.concatenating(CGAffineTransform(translationX: -center.x, y: -center.y))
        transform = transform.concatenating(CGAffineTransform(scaleX: factor, y: factor))
        transform = transform.concatenating(CGAffineTransform(translationX: rect.midX, y: rect.midY))

        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 272, y: 96))
        bezierPath.addCurve(to: CGPoint(x: 320, y: 48), controlPoint1: CGPoint(x: 298.51, y: 96), controlPoint2: CGPoint(x: 320, y: 74.51))
        bezierPath.addCurve(to: CGPoint(x: 272, y: 0), controlPoint1: CGPoint(x: 320, y: 21.49), controlPoint2: CGPoint(x: 298.51, y: 0))
        bezierPath.addCurve(to: CGPoint(x: 224, y: 48), controlPoint1: CGPoint(x: 245.49, y: 0), controlPoint2: CGPoint(x: 224, y: 21.49))
        bezierPath.addCurve(to: CGPoint(x: 272, y: 96), controlPoint1: CGPoint(x: 224, y: 74.51), controlPoint2: CGPoint(x: 245.49, y: 96))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 113.69, y: 317.47))
        bezierPath.addLine(to: CGPoint(x: 98.89, y: 351.99))
        bezierPath.addLine(to: CGPoint(x: 32, y: 351.99))
        bezierPath.addCurve(to: CGPoint(x: 0, y: 383.99), controlPoint1: CGPoint(x: 14.33, y: 351.99), controlPoint2: CGPoint(x: 0, y: 366.32))
        bezierPath.addCurve(to: CGPoint(x: 32, y: 415.99), controlPoint1: CGPoint(x: 0, y: 401.66), controlPoint2: CGPoint(x: 14.33, y: 415.99))
        bezierPath.addLine(to: CGPoint(x: 109.45, y: 415.99))
        bezierPath.addCurve(to: CGPoint(x: 153.56, y: 386.9), controlPoint1: CGPoint(x: 128.7, y: 415.99), controlPoint2: CGPoint(x: 146.03, y: 404.55))
        bezierPath.addLine(to: CGPoint(x: 162.35, y: 366.38))
        bezierPath.addLine(to: CGPoint(x: 151.68, y: 360.08))
        bezierPath.addCurve(to: CGPoint(x: 113.69, y: 317.47), controlPoint1: CGPoint(x: 134.36, y: 349.85), controlPoint2: CGPoint(x: 121.62, y: 334.71))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 384, y: 223.99))
        bezierPath.addLine(to: CGPoint(x: 339.97, y: 223.99))
        bezierPath.addLine(to: CGPoint(x: 313.91, y: 170.74))
        bezierPath.addCurve(to: CGPoint(x: 252.13, y: 119.8), controlPoint1: CGPoint(x: 301.41, y: 145.19), controlPoint2: CGPoint(x: 278.46, y: 126.51))
        bezierPath.addLine(to: CGPoint(x: 181.05, y: 98.66))
        bezierPath.addCurve(to: CGPoint(x: 100.21, y: 115.8), controlPoint1: CGPoint(x: 152.75, y: 91.86), controlPoint2: CGPoint(x: 123.28, y: 98.11))
        bezierPath.addLine(to: CGPoint(x: 60.54, y: 146.21))
        bezierPath.addCurve(to: CGPoint(x: 54.62, y: 191.07), controlPoint1: CGPoint(x: 46.51, y: 156.96), controlPoint2: CGPoint(x: 43.85, y: 177.04))
        bezierPath.addCurve(to: CGPoint(x: 99.48, y: 196.99), controlPoint1: CGPoint(x: 65.39, y: 205.1), controlPoint2: CGPoint(x: 85.46, y: 207.73))
        bezierPath.addLine(to: CGPoint(x: 139.17, y: 166.58))
        bezierPath.addCurve(to: CGPoint(x: 164.44, y: 160.44), controlPoint1: CGPoint(x: 146.84, y: 160.69), controlPoint2: CGPoint(x: 156.61, y: 158.58))
        bezierPath.addLine(to: CGPoint(x: 179.14, y: 164.81))
        bezierPath.addLine(to: CGPoint(x: 141.68, y: 252.2))
        bezierPath.addCurve(to: CGPoint(x: 167.98, y: 332.51), controlPoint1: CGPoint(x: 129.06, y: 281.68), controlPoint2: CGPoint(x: 140.37, y: 316.21))
        bezierPath.addLine(to: CGPoint(x: 252.96, y: 382.68))
        bezierPath.addLine(to: CGPoint(x: 225.49, y: 470.41))
        bezierPath.addCurve(to: CGPoint(x: 246.46, y: 510.5), controlPoint1: CGPoint(x: 220.21, y: 487.27), controlPoint2: CGPoint(x: 229.6, y: 505.22))
        bezierPath.addCurve(to: CGPoint(x: 256.04, y: 511.98), controlPoint1: CGPoint(x: 249.65, y: 511.5), controlPoint2: CGPoint(x: 252.87, y: 511.98))
        bezierPath.addCurve(to: CGPoint(x: 286.56, y: 489.53), controlPoint1: CGPoint(x: 269.65, y: 511.98), controlPoint2: CGPoint(x: 282.27, y: 503.21))
        bezierPath.addLine(to: CGPoint(x: 318.2, y: 388.47))
        bezierPath.addCurve(to: CGPoint(x: 296.56, y: 334.08), controlPoint1: CGPoint(x: 324.11, y: 367.7), controlPoint2: CGPoint(x: 315.31, y: 345.39))
        bezierPath.addLine(to: CGPoint(x: 235.32, y: 297.94))
        bezierPath.addLine(to: CGPoint(x: 266.63, y: 219.66))
        bezierPath.addLine(to: CGPoint(x: 286.9, y: 261.09))
        bezierPath.addCurve(to: CGPoint(x: 330.01, y: 287.98), controlPoint1: CGPoint(x: 294.9, y: 277.43), controlPoint2: CGPoint(x: 311.82, y: 287.98))
        bezierPath.addLine(to: CGPoint(x: 384, y: 287.98))
        bezierPath.addCurve(to: CGPoint(x: 416, y: 255.98), controlPoint1: CGPoint(x: 401.67, y: 287.98), controlPoint2: CGPoint(x: 416, y: 273.65))
        bezierPath.addCurve(to: CGPoint(x: 384, y: 223.99), controlPoint1: CGPoint(x: 416, y: 238.31), controlPoint2: CGPoint(x: 401.67, y: 223.99))
        bezierPath.close()
        bezierPath.fill()

        let path = Path(bezierPath.cgPath)
        return path.applying(transform)
    }
}

struct ClipboardIconShape: Shape {
    static let absoluteSize: CGSize = CGSize(width: 384, height: 512)

    func path(in rect: CGRect) -> Path {
        let scaleX = rect.size.width / ClipboardIconShape.absoluteSize.width
        let scaleY = rect.size.height / ClipboardIconShape.absoluteSize.height
        
        let factor = min(scaleX, max(scaleY, 0.0))
        let center = CGPoint(x: ClipboardIconShape.absoluteSize.width / 2, y: ClipboardIconShape.absoluteSize.height / 2)
        
        var transform  = CGAffineTransform.identity
        
        transform = transform.concatenating(CGAffineTransform(translationX: -center.x, y: -center.y))
        transform = transform.concatenating(CGAffineTransform(scaleX: factor, y: factor))
        transform = transform.concatenating(CGAffineTransform(translationX: rect.midX, y: rect.midY))
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 384, y: 112))
        bezierPath.addLine(to: CGPoint(x: 384, y: 464))
        bezierPath.addCurve(to: CGPoint(x: 336, y: 512), controlPoint1: CGPoint(x: 384, y: 490.51), controlPoint2: CGPoint(x: 362.51, y: 512))
        bezierPath.addLine(to: CGPoint(x: 48, y: 512))
        bezierPath.addCurve(to: CGPoint(x: 0, y: 464), controlPoint1: CGPoint(x: 21.49, y: 512), controlPoint2: CGPoint(x: 0, y: 490.51))
        bezierPath.addLine(to: CGPoint(x: 0, y: 112))
        bezierPath.addCurve(to: CGPoint(x: 48, y: 64), controlPoint1: CGPoint(x: 0, y: 85.49), controlPoint2: CGPoint(x: 21.49, y: 64))
        bezierPath.addLine(to: CGPoint(x: 128, y: 64))
        bezierPath.addCurve(to: CGPoint(x: 192, y: 0), controlPoint1: CGPoint(x: 128, y: 28.71), controlPoint2: CGPoint(x: 156.71, y: 0))
        bezierPath.addCurve(to: CGPoint(x: 256, y: 64), controlPoint1: CGPoint(x: 227.29, y: 0), controlPoint2: CGPoint(x: 256, y: 28.71))
        bezierPath.addLine(to: CGPoint(x: 336, y: 64))
        bezierPath.addCurve(to: CGPoint(x: 384, y: 112), controlPoint1: CGPoint(x: 362.51, y: 64), controlPoint2: CGPoint(x: 384, y: 85.49))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 192, y: 40))
        bezierPath.addCurve(to: CGPoint(x: 168, y: 64), controlPoint1: CGPoint(x: 178.75, y: 40), controlPoint2: CGPoint(x: 168, y: 50.75))
        bezierPath.addCurve(to: CGPoint(x: 192, y: 88), controlPoint1: CGPoint(x: 168, y: 77.25), controlPoint2: CGPoint(x: 178.75, y: 88))
        bezierPath.addCurve(to: CGPoint(x: 216, y: 64), controlPoint1: CGPoint(x: 205.25, y: 88), controlPoint2: CGPoint(x: 216, y: 77.25))
        bezierPath.addCurve(to: CGPoint(x: 192, y: 40), controlPoint1: CGPoint(x: 216, y: 50.75), controlPoint2: CGPoint(x: 205.25, y: 40))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 288, y: 154))
        bezierPath.addLine(to: CGPoint(x: 288, y: 134))
        bezierPath.addLine(to: CGPoint(x: 288, y: 134))
        bezierPath.addCurve(to: CGPoint(x: 282, y: 128), controlPoint1: CGPoint(x: 288, y: 130.69), controlPoint2: CGPoint(x: 285.31, y: 128))
        bezierPath.addLine(to: CGPoint(x: 102, y: 128))
        bezierPath.addLine(to: CGPoint(x: 102, y: 128))
        bezierPath.addCurve(to: CGPoint(x: 96, y: 134), controlPoint1: CGPoint(x: 98.69, y: 128), controlPoint2: CGPoint(x: 96, y: 130.69))
        bezierPath.addLine(to: CGPoint(x: 96, y: 154))
        bezierPath.addLine(to: CGPoint(x: 96, y: 154))
        bezierPath.addCurve(to: CGPoint(x: 102, y: 160), controlPoint1: CGPoint(x: 96, y: 157.31), controlPoint2: CGPoint(x: 98.69, y: 160))
        bezierPath.addLine(to: CGPoint(x: 282, y: 160))
        bezierPath.addLine(to: CGPoint(x: 282, y: 160))
        bezierPath.addCurve(to: CGPoint(x: 288, y: 154), controlPoint1: CGPoint(x: 285.31, y: 160), controlPoint2: CGPoint(x: 288, y: 157.31))
        bezierPath.close()
        bezierPath.fill()

        let path = Path(bezierPath.cgPath)
        return path.applying(transform)
    }
}
