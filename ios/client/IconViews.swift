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