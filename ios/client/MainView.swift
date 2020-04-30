//
//  MainView.swift
//  client
//
//  Created by Nadir Muzaffar on 3/9/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct ScaledBezier: Shape {
    let bezierPath: UIBezierPath

    func path(in rect: CGRect) -> Path {
        print(rect)
        //let path = Path(bezierPath.cgPath)

        bezierPath.fit(into: rect).moveCenter(to: rect.center).fill()
        return Path(bezierPath.cgPath)
//
//        // Figure out how much bigger we need to make our path in order for it to fill the available space without clipping.
//        let multiplier = min(rect.width, rect.height)
//
//        // Create an affine transform that uses the multiplier for both dimensions equally.
//        let transform = CGAffineTransform(scaleX: multiplier, y: multiplier)
//
//        // Apply that scale and send back the result.
//        return path
    }
}

struct MainView: View {
    @EnvironmentObject var route: RouteState
    @EnvironmentObject var userState: UserState
  
    @State var offset: CGSize = CGSize.zero
    
    var body: some View {
//        GeometryReader { geometry in
//            BezTest(size: geometry.size)
//                .border(Color.red)
//                .offset(x: self.offset.width, y: self.offset.height)
//                .gesture(DragGesture()
//                    .onChanged({ value in
//                        self.offset = value.translation
//                    })
//                )
//        }
        
        VStack {
            ScaledBezier(bezierPath: self.bodyPath())
                .stroke(Color.black, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
                .border(Color.red)
                .frame(width: 200, height: 200)
        
            Path { fMA9628Path in
                fMA9628Path.move(to: CGPoint(x: 324.5, y: 292))

                fMA9628Path.addCurve(to: CGPoint(x: 297.4, y: 304), control1: CGPoint(x: 323.2, y: 294.1), control2: CGPoint(x: 311.4, y: 299.3))
                fMA9628Path.addCurve(to: CGPoint(x: 270.2, y: 320.1), control1: CGPoint(x: 279.6, y: 309.9), control2: CGPoint(x: 274.5, y: 312.9))
                fMA9628Path.addCurve(to: CGPoint(x: 263.1, y: 349), control1: CGPoint(x: 264.8, y: 329.1), control2: CGPoint(x: 262.9, y: 336.9))
                fMA9628Path.addCurve(to: CGPoint(x: 261.7, y: 362.7), control1: CGPoint(x: 263.3, y: 357.1), control2: CGPoint(x: 262.9, y: 360.2))
                fMA9628Path.addCurve(to: CGPoint(x: 263.5, y: 385), control1: CGPoint(x: 258.6, y: 368.5), control2: CGPoint(x: 260, y: 385))
                fMA9628Path.addCurve(to: CGPoint(x: 276.1, y: 378.4), control1: CGPoint(x: 266.2, y: 385), control2: CGPoint(x: 273.6, y: 381.1))
                fMA9628Path.addCurve(to: CGPoint(x: 286.6, y: 362.6), control1: CGPoint(x: 277.5, y: 376.8), control2: CGPoint(x: 282.2, y: 369.7))
                fMA9628Path.addCurve(to: CGPoint(x: 323, y: 330.7), control1: CGPoint(x: 299.2, y: 342), control2: CGPoint(x: 312.1, y: 330.7))
                fMA9628Path.addCurve(to: CGPoint(x: 327.9, y: 327.7), control1: CGPoint(x: 326.4, y: 330.7), control2: CGPoint(x: 327, y: 330.4))
                fMA9628Path.addCurve(to: CGPoint(x: 328, y: 293.6), control1: CGPoint(x: 329.3, y: 323.9), control2: CGPoint(x: 329.3, y: 297))
                fMA9628Path.addCurve(to: CGPoint(x: 324.5, y: 292), control1: CGPoint(x: 327, y: 290.9), control2: CGPoint(x: 325.6, y: 290.3))
                //fMA9628Path.close()
                fMA9628Path.move(to: CGPoint(x: 332, y: 293.6))
                fMA9628Path.addCurve(to: CGPoint(x: 332, y: 327.6), control1: CGPoint(x: 330.7, y: 297), control2: CGPoint(x: 330.7, y: 323.9))
                fMA9628Path.addCurve(to: CGPoint(x: 337, y: 330.7), control1: CGPoint(x: 332.9, y: 330.2), control2: CGPoint(x: 333.6, y: 330.6))
                fMA9628Path.addCurve(to: CGPoint(x: 372.8, y: 362), control1: CGPoint(x: 348.9, y: 331.2), control2: CGPoint(x: 360.5, y: 341.3))
                fMA9628Path.addCurve(to: CGPoint(x: 396.4, y: 385), control1: CGPoint(x: 381, y: 375.8), control2: CGPoint(x: 390.4, y: 385))
                fMA9628Path.addCurve(to: CGPoint(x: 398.4, y: 363.2), control1: CGPoint(x: 399.8, y: 385), control2: CGPoint(x: 401.2, y: 369.9))
                fMA9628Path.addCurve(to: CGPoint(x: 396.6, y: 347), control1: CGPoint(x: 397.4, y: 360.7), control2: CGPoint(x: 396.8, y: 355.5))
                fMA9628Path.addCurve(to: CGPoint(x: 388.6, y: 318.3), control1: CGPoint(x: 396.3, y: 333.1), control2: CGPoint(x: 394.7, y: 327.1))
                fMA9628Path.addCurve(to: CGPoint(x: 364, y: 304.3), control1: CGPoint(x: 384.5, y: 312.3), control2: CGPoint(x: 378.9, y: 309.1))
                fMA9628Path.addCurve(to: CGPoint(x: 335.6, y: 292.1), control1: CGPoint(x: 351.8, y: 300.5), control2: CGPoint(x: 336.7, y: 293.9))
                fMA9628Path.addCurve(to: CGPoint(x: 332, y: 293.6), control1: CGPoint(x: 334.4, y: 290.3), control2: CGPoint(x: 333, y: 290.9))
                //fMA9628Path.close()
                fMA9628Path.move(to: CGPoint(x: 319, y: 333.9))
                fMA9628Path.addCurve(to: CGPoint(x: 288.2, y: 364.2), control1: CGPoint(x: 308, y: 337.4), control2: CGPoint(x: 299.6, y: 345.6))
                fMA9628Path.addCurve(to: CGPoint(x: 272.4, y: 384.9), control1: CGPoint(x: 282, y: 374.2), control2: CGPoint(x: 277.9, y: 379.6))
                fMA9628Path.addCurve(to: CGPoint(x: 266, y: 395.5), control1: CGPoint(x: 265.3, y: 391.7), control2: CGPoint(x: 263.8, y: 394.2))
                fMA9628Path.addCurve(to: CGPoint(x: 272.7, y: 393.1), control1: CGPoint(x: 266.5, y: 395.8), control2: CGPoint(x: 269.5, y: 394.7))
                fMA9628Path.addCurve(to: CGPoint(x: 312.2, y: 383), control1: CGPoint(x: 286.3, y: 386.1), control2: CGPoint(x: 298.1, y: 383.1))
                fMA9628Path.addCurve(to: CGPoint(x: 322.9, y: 380.4), control1: CGPoint(x: 318.9, y: 383), control2: CGPoint(x: 320.2, y: 382.7))
                fMA9628Path.addCurve(to: CGPoint(x: 328.7, y: 350.5), control1: CGPoint(x: 327.8, y: 376.3), control2: CGPoint(x: 328.9, y: 370.4))
                fMA9628Path.addLine(to: CGPoint(x: 328.4, y: 333.5))
                fMA9628Path.addLine(to: CGPoint(x: 325, y: 333.3))
                fMA9628Path.addCurve(to: CGPoint(x: 319, y: 333.9), control1: CGPoint(x: 323.1, y: 333.2), control2: CGPoint(x: 320.4, y: 333.5))
                //fMA9628Path.close()
                fMA9628Path.move(to: CGPoint(x: 331.2, y: 350.6))
                fMA9628Path.addCurve(to: CGPoint(x: 337.1, y: 380.5), control1: CGPoint(x: 331.1, y: 370.9), control2: CGPoint(x: 332.1, y: 376.2))
                fMA9628Path.addCurve(to: CGPoint(x: 346.9, y: 383), control1: CGPoint(x: 339.7, y: 382.6), control2: CGPoint(x: 341.1, y: 383))
                fMA9628Path.addCurve(to: CGPoint(x: 387.1, y: 393.1), control1: CGPoint(x: 360.5, y: 383), control2: CGPoint(x: 373.8, y: 386.3))
                fMA9628Path.addCurve(to: CGPoint(x: 394, y: 395.5), control1: CGPoint(x: 390.4, y: 394.7), control2: CGPoint(x: 393.5, y: 395.8))
                fMA9628Path.addCurve(to: CGPoint(x: 386.3, y: 382.7), control1: CGPoint(x: 396.2, y: 394.1), control2: CGPoint(x: 394.6, y: 391.4))
                fMA9628Path.addCurve(to: CGPoint(x: 370.5, y: 362.2), control1: CGPoint(x: 380.7, y: 376.8), control2: CGPoint(x: 375, y: 369.4))
                fMA9628Path.addCurve(to: CGPoint(x: 336.6, y: 333.3), control1: CGPoint(x: 359, y: 343.5), control2: CGPoint(x: 348.4, y: 334.5))
                fMA9628Path.addLine(to: CGPoint(x: 331.3, y: 332.8))
                fMA9628Path.addLine(to: CGPoint(x: 331.2, y: 350.6))
                //fMA9628Path.close()
                fMA9628Path.move(to: CGPoint(x: 307.5, y: 386.1))
                fMA9628Path.addCurve(to: CGPoint(x: 269.1, y: 397.4), control1: CGPoint(x: 290.8, y: 387.2), control2: CGPoint(x: 280.6, y: 390.2))
                fMA9628Path.addCurve(to: CGPoint(x: 265.2, y: 405.1), control1: CGPoint(x: 264.8, y: 400.2), control2: CGPoint(x: 264.8, y: 400.2))
                fMA9628Path.addCurve(to: CGPoint(x: 272, y: 419.5), control1: CGPoint(x: 265.6, y: 408.9), control2: CGPoint(x: 267, y: 411.9))
                fMA9628Path.addCurve(to: CGPoint(x: 299.1, y: 437.1), control1: CGPoint(x: 282.4, y: 435.3), control2: CGPoint(x: 288.5, y: 439.3))
                fMA9628Path.addCurve(to: CGPoint(x: 321, y: 424.3), control1: CGPoint(x: 308.2, y: 435.2), control2: CGPoint(x: 316.4, y: 430.4))
                fMA9628Path.addCurve(to: CGPoint(x: 328, y: 402), control1: CGPoint(x: 326.6, y: 417), control2: CGPoint(x: 328, y: 412.4))
                fMA9628Path.addCurve(to: CGPoint(x: 320.8, y: 385.2), control1: CGPoint(x: 328, y: 389.9), control2: CGPoint(x: 325.7, y: 384.6))
                fMA9628Path.addCurve(to: CGPoint(x: 307.5, y: 386.1), control1: CGPoint(x: 320.1, y: 385.2), control2: CGPoint(x: 314.1, y: 385.7))
                //fMA9628Path.close()
                fMA9628Path.move(to: CGPoint(x: 335.6, y: 386.4))
                fMA9628Path.addCurve(to: CGPoint(x: 332, y: 401.9), control1: CGPoint(x: 333, y: 388.3), control2: CGPoint(x: 332, y: 392.8))
                fMA9628Path.addCurve(to: CGPoint(x: 338.5, y: 423.8), control1: CGPoint(x: 332, y: 412.2), control2: CGPoint(x: 333.4, y: 416.9))
                fMA9628Path.addCurve(to: CGPoint(x: 370.3, y: 437.1), control1: CGPoint(x: 345.5, y: 433.1), control2: CGPoint(x: 361.3, y: 439.7))
                fMA9628Path.addCurve(to: CGPoint(x: 394.2, y: 400.4), control1: CGPoint(x: 380.7, y: 434), control2: CGPoint(x: 398.5, y: 406.8))
                fMA9628Path.addCurve(to: CGPoint(x: 376.9, y: 390.6), control1: CGPoint(x: 392.9, y: 398.4), control2: CGPoint(x: 383.5, y: 393.1))
                fMA9628Path.addCurve(to: CGPoint(x: 335.6, y: 386.4), control1: CGPoint(x: 366.4, y: 386.7), control2: CGPoint(x: 338.9, y: 383.8))
                //fMA9628Path.close()
                fMA9628Path.move(to: CGPoint(x: 320, y: 432))
                fMA9628Path.addCurve(to: CGPoint(x: 311, y: 435.3), control1: CGPoint(x: 317.5, y: 432.4), control2: CGPoint(x: 313.5, y: 433.9))
                fMA9628Path.addCurve(to: CGPoint(x: 293.1, y: 439.5), control1: CGPoint(x: 305.3, y: 438.4), control2: CGPoint(x: 297, y: 440.4))
                fMA9628Path.addCurve(to: CGPoint(x: 279.2, y: 445.8), control1: CGPoint(x: 289.1, y: 438.6), control2: CGPoint(x: 282, y: 441.8))
                fMA9628Path.addCurve(to: CGPoint(x: 275.4, y: 467.3), control1: CGPoint(x: 276, y: 450.2), control2: CGPoint(x: 274.6, y: 458.1))
                fMA9628Path.addCurve(to: CGPoint(x: 285.7, y: 495.4), control1: CGPoint(x: 276.2, y: 476.4), control2: CGPoint(x: 278.8, y: 483.5))
                fMA9628Path.addCurve(to: CGPoint(x: 298.5, y: 519.1), control1: CGPoint(x: 288.3, y: 499.8), control2: CGPoint(x: 294.1, y: 510.5))
                fMA9628Path.addCurve(to: CGPoint(x: 313.5, y: 541), control1: CGPoint(x: 305.8, y: 533.4), control2: CGPoint(x: 307.1, y: 535.2))
                fMA9628Path.addCurve(to: CGPoint(x: 349.3, y: 540.4), control1: CGPoint(x: 328.3, y: 554.2), control2: CGPoint(x: 335.9, y: 554.1))
                fMA9628Path.addCurve(to: CGPoint(x: 362.9, y: 519.8), control1: CGPoint(x: 354.2, y: 535.4), control2: CGPoint(x: 357, y: 531.1))
                fMA9628Path.addCurve(to: CGPoint(x: 376.6, y: 494), control1: CGPoint(x: 366.9, y: 511.9), control2: CGPoint(x: 373.1, y: 500.3))
                fMA9628Path.addCurve(to: CGPoint(x: 385.8, y: 460), control1: CGPoint(x: 384.5, y: 479.7), control2: CGPoint(x: 386.3, y: 472.8))
                fMA9628Path.addCurve(to: CGPoint(x: 383.5, y: 447), control1: CGPoint(x: 385.5, y: 452.8), control2: CGPoint(x: 385, y: 449.6))
                fMA9628Path.addCurve(to: CGPoint(x: 368.5, y: 439.3), control1: CGPoint(x: 380.8, y: 442.3), control2: CGPoint(x: 373.8, y: 438.8))
                fMA9628Path.addCurve(to: CGPoint(x: 348, y: 434.9), control1: CGPoint(x: 362.5, y: 439.9), control2: CGPoint(x: 354.2, y: 438.2))
                fMA9628Path.addCurve(to: CGPoint(x: 333.4, y: 431.6), control1: CGPoint(x: 343.3, y: 432.5), control2: CGPoint(x: 340.9, y: 431.9))
                fMA9628Path.addCurve(to: CGPoint(x: 320, y: 432), control1: CGPoint(x: 328.5, y: 431.4), control2: CGPoint(x: 322.5, y: 431.6))
                //fMA9628Path.close()
                fMA9628Path.move(to: CGPoint(x: 339.5, y: 437.5))
                fMA9628Path.addCurve(to: CGPoint(x: 341.4, y: 442), control1: CGPoint(x: 341.9, y: 439.8), control2: CGPoint(x: 342.8, y: 442))
                fMA9628Path.addCurve(to: CGPoint(x: 339.4, y: 440.2), control1: CGPoint(x: 341, y: 442), control2: CGPoint(x: 340.1, y: 441.2))
                fMA9628Path.addCurve(to: CGPoint(x: 336, y: 440.6), control1: CGPoint(x: 338.2, y: 438.6), control2: CGPoint(x: 338, y: 438.6))
                fMA9628Path.addCurve(to: CGPoint(x: 332.8, y: 451.6), control1: CGPoint(x: 334.3, y: 442.3), control2: CGPoint(x: 333.6, y: 444.7))
                fMA9628Path.addCurve(to: CGPoint(x: 333.5, y: 496.7), control1: CGPoint(x: 331.8, y: 460.8), control2: CGPoint(x: 332.3, y: 492.8))
                fMA9628Path.addCurve(to: CGPoint(x: 333.2, y: 499), control1: CGPoint(x: 334, y: 498.1), control2: CGPoint(x: 333.8, y: 499))
                fMA9628Path.addCurve(to: CGPoint(x: 331.4, y: 495.5), control1: CGPoint(x: 332.6, y: 499), control2: CGPoint(x: 331.8, y: 497.4))
                fMA9628Path.addCurve(to: CGPoint(x: 328.3, y: 495), control1: CGPoint(x: 330.6, y: 491.2), control2: CGPoint(x: 329.2, y: 491))
                fMA9628Path.addCurve(to: CGPoint(x: 326.7, y: 493.8), control1: CGPoint(x: 327.3, y: 500.5), control2: CGPoint(x: 325.9, y: 499.5))
                fMA9628Path.addCurve(to: CGPoint(x: 327.4, y: 467.3), control1: CGPoint(x: 327.1, y: 490.9), control2: CGPoint(x: 327.5, y: 479))
                fMA9628Path.addCurve(to: CGPoint(x: 325.7, y: 443.6), control1: CGPoint(x: 327.3, y: 449.5), control2: CGPoint(x: 327.1, y: 445.7))
                fMA9628Path.addCurve(to: CGPoint(x: 318.9, y: 441.1), control1: CGPoint(x: 323.7, y: 440.6), control2: CGPoint(x: 320.1, y: 439.2))
                fMA9628Path.addCurve(to: CGPoint(x: 317.4, y: 441.7), control1: CGPoint(x: 318.5, y: 441.8), control2: CGPoint(x: 317.8, y: 442.1))
                fMA9628Path.addCurve(to: CGPoint(x: 319.5, y: 438), control1: CGPoint(x: 317, y: 441.3), control2: CGPoint(x: 317.9, y: 439.6))
                fMA9628Path.addCurve(to: CGPoint(x: 329.7, y: 435), control1: CGPoint(x: 322.2, y: 435.2), control2: CGPoint(x: 322.9, y: 435))
                fMA9628Path.addCurve(to: CGPoint(x: 339.5, y: 437.5), control1: CGPoint(x: 336.2, y: 435), control2: CGPoint(x: 337.4, y: 435.3))
            }
            .stroke(Color.black, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
            .border(Color.red)
            .frame(width: 100, height: 100)
            .offset(x: self.offset.width, y: self.offset.height)
            .gesture(DragGesture()
                .onChanged({ value in
                    self.offset = value.translation
                })
            )
        }
    }
    
    func bodyPath() -> UIBezierPath {
        let bodybackgroundPath = UIBezierPath()
        bodybackgroundPath.move(to: CGPoint(x: 316.6, y: 1.5))
        bodybackgroundPath.addCurve(to: CGPoint(x: 295.9, y: 12.2), controlPoint1: CGPoint(x: 309.6, y: 3.3), controlPoint2: CGPoint(x: 299.8, y: 8.4))
        bodybackgroundPath.addCurve(to: CGPoint(x: 286, y: 35.2), controlPoint1: CGPoint(x: 291.5, y: 16.6), controlPoint2: CGPoint(x: 287.2, y: 26.6))
        bodybackgroundPath.addCurve(to: CGPoint(x: 286.3, y: 82.9), controlPoint1: CGPoint(x: 284.1, y: 48), controlPoint2: CGPoint(x: 284.3, y: 73.2))
        bodybackgroundPath.addCurve(to: CGPoint(x: 288, y: 98.4), controlPoint1: CGPoint(x: 287.2, y: 87.5), controlPoint2: CGPoint(x: 288, y: 94.4))
        bodybackgroundPath.addCurve(to: CGPoint(x: 292.1, y: 119.4), controlPoint1: CGPoint(x: 288.1, y: 106.6), controlPoint2: CGPoint(x: 289.2, y: 112.5))
        bodybackgroundPath.addCurve(to: CGPoint(x: 293.5, y: 133.4), controlPoint1: CGPoint(x: 293.9, y: 123.7), controlPoint2: CGPoint(x: 294.1, y: 125.5))
        bodybackgroundPath.addCurve(to: CGPoint(x: 291.9, y: 145.6), controlPoint1: CGPoint(x: 293.2, y: 138.4), controlPoint2: CGPoint(x: 292.4, y: 143.9))
        bodybackgroundPath.addCurve(to: CGPoint(x: 270.5, y: 163.2), controlPoint1: CGPoint(x: 290.4, y: 150.4), controlPoint2: CGPoint(x: 284.6, y: 155.2))
        bodybackgroundPath.addCurve(to: CGPoint(x: 246.8, y: 177.7), controlPoint1: CGPoint(x: 263.4, y: 167.3), controlPoint2: CGPoint(x: 252.7, y: 173.8))
        bodybackgroundPath.addCurve(to: CGPoint(x: 232.8, y: 185.5), controlPoint1: CGPoint(x: 240.9, y: 181.6), controlPoint2: CGPoint(x: 234.6, y: 185.1))
        bodybackgroundPath.addCurve(to: CGPoint(x: 206, y: 200.5), controlPoint1: CGPoint(x: 225.8, y: 186.9), controlPoint2: CGPoint(x: 213.5, y: 193.9))
        bodybackgroundPath.addCurve(to: CGPoint(x: 183.3, y: 224.1), controlPoint1: CGPoint(x: 190.9, y: 214), controlPoint2: CGPoint(x: 188.2, y: 216.7))
        bodybackgroundPath.addCurve(to: CGPoint(x: 161.6, y: 286.9), controlPoint1: CGPoint(x: 170.6, y: 242.8), controlPoint2: CGPoint(x: 165.2, y: 258.6))
        bodybackgroundPath.addCurve(to: CGPoint(x: 153.6, y: 312.9), controlPoint1: CGPoint(x: 160.1, y: 298.5), controlPoint2: CGPoint(x: 159.6, y: 300))
        bodybackgroundPath.addCurve(to: CGPoint(x: 144.5, y: 334), controlPoint1: CGPoint(x: 150.1, y: 320.4), controlPoint2: CGPoint(x: 146, y: 329.9))
        bodybackgroundPath.addCurve(to: CGPoint(x: 131.2, y: 352.5), controlPoint1: CGPoint(x: 142.1, y: 340.8), controlPoint2: CGPoint(x: 141, y: 342.4))
        bodybackgroundPath.addCurve(to: CGPoint(x: 84.4, y: 419.2), controlPoint1: CGPoint(x: 110.6, y: 373.7), controlPoint2: CGPoint(x: 101, y: 387.3))
        bodybackgroundPath.addCurve(to: CGPoint(x: 58.2, y: 461.9), controlPoint1: CGPoint(x: 71.8, y: 443.3), controlPoint2: CGPoint(x: 64.6, y: 455))
        bodybackgroundPath.addLine(to: CGPoint(x: 54.1, y: 466.2))
        bodybackgroundPath.addLine(to: CGPoint(x: 46.3, y: 465.4))
        bodybackgroundPath.addCurve(to: CGPoint(x: 22.3, y: 469.9), controlPoint1: CGPoint(x: 34.5, y: 464.2), controlPoint2: CGPoint(x: 33.2, y: 464.4))
        bodybackgroundPath.addCurve(to: CGPoint(x: 6, y: 482.5), controlPoint1: CGPoint(x: 10.4, y: 475.9), controlPoint2: CGPoint(x: 6, y: 479.3))
        bodybackgroundPath.addCurve(to: CGPoint(x: 13.3, y: 486.5), controlPoint1: CGPoint(x: 6, y: 486), controlPoint2: CGPoint(x: 8.4, y: 487.4))
        bodybackgroundPath.addCurve(to: CGPoint(x: 20.5, y: 485.7), controlPoint1: CGPoint(x: 15.6, y: 486.1), controlPoint2: CGPoint(x: 18.9, y: 485.7))
        bodybackgroundPath.addCurve(to: CGPoint(x: 23.4, y: 490), controlPoint1: CGPoint(x: 23.4, y: 485.5), controlPoint2: CGPoint(x: 23.5, y: 485.6))
        bodybackgroundPath.addCurve(to: CGPoint(x: 15.3, y: 507.6), controlPoint1: CGPoint(x: 23.3, y: 493.8), controlPoint2: CGPoint(x: 22, y: 496.6))
        bodybackgroundPath.addCurve(to: CGPoint(x: 1, y: 538.3), controlPoint1: CGPoint(x: 7, y: 521.2), controlPoint2: CGPoint(x: 1, y: 534.1))
        bodybackgroundPath.addCurve(to: CGPoint(x: 6.5, y: 542.6), controlPoint1: CGPoint(x: 1, y: 541.5), controlPoint2: CGPoint(x: 3.3, y: 543.4))
        bodybackgroundPath.addCurve(to: CGPoint(x: 12.1, y: 535.7), controlPoint1: CGPoint(x: 8.3, y: 542.1), controlPoint2: CGPoint(x: 9.8, y: 540.2))
        bodybackgroundPath.addCurve(to: CGPoint(x: 21.8, y: 521), controlPoint1: CGPoint(x: 16.6, y: 526.6), controlPoint2: CGPoint(x: 20.3, y: 521))
        bodybackgroundPath.addCurve(to: CGPoint(x: 18, y: 535.8), controlPoint1: CGPoint(x: 23.7, y: 521), controlPoint2: CGPoint(x: 23.3, y: 522.8))
        bodybackgroundPath.addCurve(to: CGPoint(x: 13, y: 549.9), controlPoint1: CGPoint(x: 15.2, y: 542.6), controlPoint2: CGPoint(x: 13, y: 548.9))
        bodybackgroundPath.addCurve(to: CGPoint(x: 18.8, y: 553.4), controlPoint1: CGPoint(x: 13, y: 552.9), controlPoint2: CGPoint(x: 15.7, y: 554.5))
        bodybackgroundPath.addCurve(to: CGPoint(x: 28, y: 540), controlPoint1: CGPoint(x: 20.9, y: 552.7), controlPoint2: CGPoint(x: 22.9, y: 549.8))
        bodybackgroundPath.addCurve(to: CGPoint(x: 35.9, y: 527.2), controlPoint1: CGPoint(x: 31.6, y: 533.2), controlPoint2: CGPoint(x: 35.1, y: 527.4))
        bodybackgroundPath.addCurve(to: CGPoint(x: 32.6, y: 542.4), controlPoint1: CGPoint(x: 38.2, y: 526.4), controlPoint2: CGPoint(x: 36.7, y: 533.7))
        bodybackgroundPath.addCurve(to: CGPoint(x: 29, y: 552.6), controlPoint1: CGPoint(x: 30.6, y: 546.8), controlPoint2: CGPoint(x: 29, y: 551.3))
        bodybackgroundPath.addCurve(to: CGPoint(x: 39.1, y: 550.2), controlPoint1: CGPoint(x: 29, y: 558.1), controlPoint2: CGPoint(x: 34.7, y: 556.7))
        bodybackgroundPath.addCurve(to: CGPoint(x: 42.6, y: 545.1), controlPoint1: CGPoint(x: 40.9, y: 547.6), controlPoint2: CGPoint(x: 42.5, y: 545.3))
        bodybackgroundPath.addCurve(to: CGPoint(x: 47.5, y: 544.5), controlPoint1: CGPoint(x: 42.8, y: 544.9), controlPoint2: CGPoint(x: 45, y: 544.6))
        bodybackgroundPath.addCurve(to: CGPoint(x: 62.3, y: 532.1), controlPoint1: CGPoint(x: 53, y: 544.3), controlPoint2: CGPoint(x: 56, y: 541.7))
        bodybackgroundPath.addCurve(to: CGPoint(x: 70.7, y: 520.2), controlPoint1: CGPoint(x: 64.6, y: 528.4), controlPoint2: CGPoint(x: 68.4, y: 523.1))
        bodybackgroundPath.addCurve(to: CGPoint(x: 81.6, y: 498.4), controlPoint1: CGPoint(x: 76.3, y: 513.3), controlPoint2: CGPoint(x: 79.5, y: 506.8))
        bodybackgroundPath.addCurve(to: CGPoint(x: 93.4, y: 481.7), controlPoint1: CGPoint(x: 83.2, y: 491.7), controlPoint2: CGPoint(x: 83.5, y: 491.3))
        bodybackgroundPath.addCurve(to: CGPoint(x: 120.5, y: 457.2), controlPoint1: CGPoint(x: 98.9, y: 476.3), controlPoint2: CGPoint(x: 111.2, y: 465.3))
        bodybackgroundPath.addCurve(to: CGPoint(x: 163.1, y: 412.5), controlPoint1: CGPoint(x: 144.2, y: 436.8), controlPoint2: CGPoint(x: 153.7, y: 426.8))
        bodybackgroundPath.addCurve(to: CGPoint(x: 174.9, y: 394.9), controlPoint1: CGPoint(x: 167.4, y: 405.9), controlPoint2: CGPoint(x: 172.7, y: 398))
        bodybackgroundPath.addCurve(to: CGPoint(x: 184.1, y: 379.4), controlPoint1: CGPoint(x: 177.1, y: 391.8), controlPoint2: CGPoint(x: 181.2, y: 384.8))
        bodybackgroundPath.addCurve(to: CGPoint(x: 193, y: 364.5), controlPoint1: CGPoint(x: 186.9, y: 374), controlPoint2: CGPoint(x: 190.9, y: 367.2))
        bodybackgroundPath.addCurve(to: CGPoint(x: 209, y: 334.5), controlPoint1: CGPoint(x: 197.9, y: 358.2), controlPoint2: CGPoint(x: 204.9, y: 344.9))
        bodybackgroundPath.addCurve(to: CGPoint(x: 218.8, y: 326.6), controlPoint1: CGPoint(x: 216.1, y: 315.9), controlPoint2: CGPoint(x: 217.1, y: 315.2))
        bodybackgroundPath.addCurve(to: CGPoint(x: 236, y: 380.5), controlPoint1: CGPoint(x: 219.9, y: 333.7), controlPoint2: CGPoint(x: 222.4, y: 341.6))
        bodybackgroundPath.addLine(to: CGPoint(x: 241.3, y: 395.5))
        bodybackgroundPath.addLine(to: CGPoint(x: 240.7, y: 412.1))
        bodybackgroundPath.addCurve(to: CGPoint(x: 237.1, y: 442.6), controlPoint1: CGPoint(x: 240.2, y: 425), controlPoint2: CGPoint(x: 239.4, y: 431.9))
        bodybackgroundPath.addCurve(to: CGPoint(x: 234.7, y: 470), controlPoint1: CGPoint(x: 234.4, y: 455.3), controlPoint2: CGPoint(x: 234.2, y: 457.6))
        bodybackgroundPath.addCurve(to: CGPoint(x: 233.6, y: 498.3), controlPoint1: CGPoint(x: 235.1, y: 479.5), controlPoint2: CGPoint(x: 234.7, y: 487.9))
        bodybackgroundPath.addCurve(to: CGPoint(x: 231.1, y: 530.8), controlPoint1: CGPoint(x: 232.6, y: 506.4), controlPoint2: CGPoint(x: 231.5, y: 521.1))
        bodybackgroundPath.addLine(to: CGPoint(x: 230.3, y: 548.5))
        bodybackgroundPath.addLine(to: CGPoint(x: 224.2, y: 566.5))
        bodybackgroundPath.addCurve(to: CGPoint(x: 212.3, y: 657.5), controlPoint1: CGPoint(x: 213.9, y: 596.9), controlPoint2: CGPoint(x: 211.4, y: 616.5))
        bodybackgroundPath.addCurve(to: CGPoint(x: 221.6, y: 734.1), controlPoint1: CGPoint(x: 213, y: 687.6), controlPoint2: CGPoint(x: 215.2, y: 706.1))
        bodybackgroundPath.addCurve(to: CGPoint(x: 233.8, y: 773), controlPoint1: CGPoint(x: 223.9, y: 744.4), controlPoint2: CGPoint(x: 226.2, y: 751.8))
        bodybackgroundPath.addCurve(to: CGPoint(x: 240, y: 791.7), controlPoint1: CGPoint(x: 235.5, y: 777.7), controlPoint2: CGPoint(x: 238.3, y: 786.1))
        bodybackgroundPath.addCurve(to: CGPoint(x: 242.7, y: 815.2), controlPoint1: CGPoint(x: 243.1, y: 801.6), controlPoint2: CGPoint(x: 243.2, y: 802.4))
        bodybackgroundPath.addCurve(to: CGPoint(x: 238.9, y: 842.5), controlPoint1: CGPoint(x: 242.3, y: 825.5), controlPoint2: CGPoint(x: 241.5, y: 831.7))
        bodybackgroundPath.addCurve(to: CGPoint(x: 235.7, y: 871.5), controlPoint1: CGPoint(x: 235.9, y: 855.2), controlPoint2: CGPoint(x: 235.6, y: 857.9))
        bodybackgroundPath.addCurve(to: CGPoint(x: 251.5, y: 955), controlPoint1: CGPoint(x: 235.7, y: 894.5), controlPoint2: CGPoint(x: 240.1, y: 917.6))
        bodybackgroundPath.addCurve(to: CGPoint(x: 262.7, y: 1008.5), controlPoint1: CGPoint(x: 262.1, y: 989.5), controlPoint2: CGPoint(x: 262.2, y: 989.8))
        bodybackgroundPath.addCurve(to: CGPoint(x: 261.3, y: 1035), controlPoint1: CGPoint(x: 263.1, y: 1022.8), controlPoint2: CGPoint(x: 262.9, y: 1027))
        bodybackgroundPath.addCurve(to: CGPoint(x: 259.7, y: 1049), controlPoint1: CGPoint(x: 260.2, y: 1040.2), controlPoint2: CGPoint(x: 259.5, y: 1046.5))
        bodybackgroundPath.addCurve(to: CGPoint(x: 245.3, y: 1086.2), controlPoint1: CGPoint(x: 260.3, y: 1055.1), controlPoint2: CGPoint(x: 253.1, y: 1073.6))
        bodybackgroundPath.addCurve(to: CGPoint(x: 236, y: 1111.1), controlPoint1: CGPoint(x: 239.8, y: 1095.1), controlPoint2: CGPoint(x: 236, y: 1105.3))
        bodybackgroundPath.addCurve(to: CGPoint(x: 256.1, y: 1122.8), controlPoint1: CGPoint(x: 236, y: 1116.5), controlPoint2: CGPoint(x: 247.4, y: 1123.2))
        bodybackgroundPath.addCurve(to: CGPoint(x: 262.1, y: 1124.3), controlPoint1: CGPoint(x: 258.1, y: 1122.7), controlPoint2: CGPoint(x: 260.8, y: 1123.4))
        bodybackgroundPath.addCurve(to: CGPoint(x: 270.8, y: 1124.4), controlPoint1: CGPoint(x: 265, y: 1126.4), controlPoint2: CGPoint(x: 267.9, y: 1126.4))
        bodybackgroundPath.addCurve(to: CGPoint(x: 277.4, y: 1124.5), controlPoint1: CGPoint(x: 272.8, y: 1123), controlPoint2: CGPoint(x: 273.4, y: 1123))
        bodybackgroundPath.addCurve(to: CGPoint(x: 292, y: 1117.4), controlPoint1: CGPoint(x: 283.8, y: 1127), controlPoint2: CGPoint(x: 287.7, y: 1125))
        bodybackgroundPath.addCurve(to: CGPoint(x: 300.1, y: 1095), controlPoint1: CGPoint(x: 298.6, y: 1105.6), controlPoint2: CGPoint(x: 299.1, y: 1104.2))
        bodybackgroundPath.addCurve(to: CGPoint(x: 303.2, y: 1081.1), controlPoint1: CGPoint(x: 300.6, y: 1089.4), controlPoint2: CGPoint(x: 301.9, y: 1083.9))
        bodybackgroundPath.addCurve(to: CGPoint(x: 306.1, y: 1070), controlPoint1: CGPoint(x: 304.4, y: 1078.6), controlPoint2: CGPoint(x: 305.7, y: 1073.6))
        bodybackgroundPath.addCurve(to: CGPoint(x: 309, y: 1057.6), controlPoint1: CGPoint(x: 306.5, y: 1066.4), controlPoint2: CGPoint(x: 307.8, y: 1060.8))
        bodybackgroundPath.addCurve(to: CGPoint(x: 309.5, y: 1042.6), controlPoint1: CGPoint(x: 311.1, y: 1051.7), controlPoint2: CGPoint(x: 311.1, y: 1051.5))
        bodybackgroundPath.addCurve(to: CGPoint(x: 307.3, y: 1009), controlPoint1: CGPoint(x: 308.3, y: 1036.3), controlPoint2: CGPoint(x: 307.6, y: 1025.8))
        bodybackgroundPath.addCurve(to: CGPoint(x: 316.1, y: 917.2), controlPoint1: CGPoint(x: 306.7, y: 981.6), controlPoint2: CGPoint(x: 307.7, y: 971.5))
        bodybackgroundPath.addCurve(to: CGPoint(x: 319.7, y: 879), controlPoint1: CGPoint(x: 319.7, y: 893.8), controlPoint2: CGPoint(x: 320.1, y: 889.1))
        bodybackgroundPath.addCurve(to: CGPoint(x: 305.4, y: 819), controlPoint1: CGPoint(x: 318.9, y: 860.1), controlPoint2: CGPoint(x: 316, y: 848))
        bodybackgroundPath.addCurve(to: CGPoint(x: 304.4, y: 790.4), controlPoint1: CGPoint(x: 301.4, y: 807.9), controlPoint2: CGPoint(x: 301.1, y: 800.1))
        bodybackgroundPath.addCurve(to: CGPoint(x: 311.5, y: 746.5), controlPoint1: CGPoint(x: 307, y: 782.5), controlPoint2: CGPoint(x: 308.6, y: 772.7))
        bodybackgroundPath.addCurve(to: CGPoint(x: 323.2, y: 648.5), controlPoint1: CGPoint(x: 313.3, y: 729.9), controlPoint2: CGPoint(x: 318.7, y: 684.8))
        bodybackgroundPath.addCurve(to: CGPoint(x: 326.4, y: 601), controlPoint1: CGPoint(x: 325.8, y: 627), controlPoint2: CGPoint(x: 326.4, y: 618.8))
        bodybackgroundPath.addCurve(to: CGPoint(x: 328.4, y: 579.2), controlPoint1: CGPoint(x: 326.5, y: 580.9), controlPoint2: CGPoint(x: 326.6, y: 579.5))
        bodybackgroundPath.addCurve(to: CGPoint(x: 332.5, y: 601.2), controlPoint1: CGPoint(x: 332, y: 578.5), controlPoint2: CGPoint(x: 332.3, y: 580.4))
        bodybackgroundPath.addCurve(to: CGPoint(x: 342.4, y: 703), controlPoint1: CGPoint(x: 332.6, y: 622.2), controlPoint2: CGPoint(x: 332.4, y: 620))
        bodybackgroundPath.addCurve(to: CGPoint(x: 347.5, y: 746), controlPoint1: CGPoint(x: 344.3, y: 718.7), controlPoint2: CGPoint(x: 346.6, y: 738))
        bodybackgroundPath.addCurve(to: CGPoint(x: 355.1, y: 790.5), controlPoint1: CGPoint(x: 350.3, y: 771.6), controlPoint2: CGPoint(x: 352, y: 781.3))
        bodybackgroundPath.addCurve(to: CGPoint(x: 351.5, y: 824.8), controlPoint1: CGPoint(x: 359.1, y: 802), controlPoint2: CGPoint(x: 358.7, y: 805.4))
        bodybackgroundPath.addCurve(to: CGPoint(x: 340.5, y: 865.4), controlPoint1: CGPoint(x: 345.1, y: 842), controlPoint2: CGPoint(x: 342.7, y: 851.1))
        bodybackgroundPath.addCurve(to: CGPoint(x: 343, y: 917.5), controlPoint1: CGPoint(x: 338.2, y: 880.9), controlPoint2: CGPoint(x: 338.6, y: 889))
        bodybackgroundPath.addCurve(to: CGPoint(x: 351.7, y: 1008.5), controlPoint1: CGPoint(x: 351.5, y: 973.3), controlPoint2: CGPoint(x: 352.2, y: 980.8))
        bodybackgroundPath.addCurve(to: CGPoint(x: 349.5, y: 1042.6), controlPoint1: CGPoint(x: 351.4, y: 1025.9), controlPoint2: CGPoint(x: 350.7, y: 1036.3))
        bodybackgroundPath.addCurve(to: CGPoint(x: 350, y: 1057.6), controlPoint1: CGPoint(x: 347.9, y: 1051.5), controlPoint2: CGPoint(x: 347.9, y: 1051.7))
        bodybackgroundPath.addCurve(to: CGPoint(x: 352.9, y: 1070), controlPoint1: CGPoint(x: 351.2, y: 1060.8), controlPoint2: CGPoint(x: 352.5, y: 1066.4))
        bodybackgroundPath.addCurve(to: CGPoint(x: 355.8, y: 1081.1), controlPoint1: CGPoint(x: 353.3, y: 1073.6), controlPoint2: CGPoint(x: 354.6, y: 1078.6))
        bodybackgroundPath.addCurve(to: CGPoint(x: 358.9, y: 1095), controlPoint1: CGPoint(x: 357.1, y: 1083.9), controlPoint2: CGPoint(x: 358.4, y: 1089.4))
        bodybackgroundPath.addCurve(to: CGPoint(x: 367, y: 1117.4), controlPoint1: CGPoint(x: 359.9, y: 1104.2), controlPoint2: CGPoint(x: 360.4, y: 1105.6))
        bodybackgroundPath.addCurve(to: CGPoint(x: 381.6, y: 1124.5), controlPoint1: CGPoint(x: 371.3, y: 1125), controlPoint2: CGPoint(x: 375.2, y: 1127))
        bodybackgroundPath.addCurve(to: CGPoint(x: 388.2, y: 1124.4), controlPoint1: CGPoint(x: 385.6, y: 1123), controlPoint2: CGPoint(x: 386.2, y: 1123))
        bodybackgroundPath.addCurve(to: CGPoint(x: 396.9, y: 1124.3), controlPoint1: CGPoint(x: 391.1, y: 1126.4), controlPoint2: CGPoint(x: 394, y: 1126.4))
        bodybackgroundPath.addCurve(to: CGPoint(x: 402.9, y: 1122.8), controlPoint1: CGPoint(x: 398.2, y: 1123.4), controlPoint2: CGPoint(x: 400.9, y: 1122.7))
        bodybackgroundPath.addCurve(to: CGPoint(x: 423, y: 1111.1), controlPoint1: CGPoint(x: 411.6, y: 1123.2), controlPoint2: CGPoint(x: 423, y: 1116.5))
        bodybackgroundPath.addCurve(to: CGPoint(x: 413.7, y: 1086.2), controlPoint1: CGPoint(x: 423, y: 1105.3), controlPoint2: CGPoint(x: 419.2, y: 1095.1))
        bodybackgroundPath.addCurve(to: CGPoint(x: 403.4, y: 1065.2), controlPoint1: CGPoint(x: 410.5, y: 1081.1), controlPoint2: CGPoint(x: 405.9, y: 1071.6))
        bodybackgroundPath.addCurve(to: CGPoint(x: 399.3, y: 1048.6), controlPoint1: CGPoint(x: 399.6, y: 1055.4), controlPoint2: CGPoint(x: 398.9, y: 1052.7))
        bodybackgroundPath.addCurve(to: CGPoint(x: 398.3, y: 1038.1), controlPoint1: CGPoint(x: 399.5, y: 1045.9), controlPoint2: CGPoint(x: 399.1, y: 1041.1))
        bodybackgroundPath.addCurve(to: CGPoint(x: 396.3, y: 1016.5), controlPoint1: CGPoint(x: 397.5, y: 1035), controlPoint2: CGPoint(x: 396.6, y: 1025.3))
        bodybackgroundPath.addCurve(to: CGPoint(x: 406.1, y: 960), controlPoint1: CGPoint(x: 395.6, y: 996.7), controlPoint2: CGPoint(x: 396.5, y: 991.9))
        bodybackgroundPath.addCurve(to: CGPoint(x: 423.2, y: 881.8), controlPoint1: CGPoint(x: 417.4, y: 922.3), controlPoint2: CGPoint(x: 421.1, y: 905.4))
        bodybackgroundPath.addCurve(to: CGPoint(x: 419.4, y: 839.5), controlPoint1: CGPoint(x: 424.5, y: 867.2), controlPoint2: CGPoint(x: 423.6, y: 857.2))
        bodybackgroundPath.addCurve(to: CGPoint(x: 416.3, y: 814), controlPoint1: CGPoint(x: 417.3, y: 831), controlPoint2: CGPoint(x: 416.6, y: 825.2))
        bodybackgroundPath.addLine(to: CGPoint(x: 415.9, y: 799.5))
        bodybackgroundPath.addLine(to: CGPoint(x: 421.9, y: 782.5))
        bodybackgroundPath.addCurve(to: CGPoint(x: 431, y: 756.5), controlPoint1: CGPoint(x: 425.1, y: 773.1), controlPoint2: CGPoint(x: 429.2, y: 761.4))
        bodybackgroundPath.addCurve(to: CGPoint(x: 446, y: 680.5), controlPoint1: CGPoint(x: 437.4, y: 738.4), controlPoint2: CGPoint(x: 443.8, y: 705.7))
        bodybackgroundPath.addCurve(to: CGPoint(x: 445.9, y: 617.4), controlPoint1: CGPoint(x: 447.3, y: 664.8), controlPoint2: CGPoint(x: 447.3, y: 631.2))
        bodybackgroundPath.addCurve(to: CGPoint(x: 434.3, y: 565), controlPoint1: CGPoint(x: 444.3, y: 600.4), controlPoint2: CGPoint(x: 440.4, y: 583))
        bodybackgroundPath.addLine(to: CGPoint(x: 428.7, y: 548.5))
        bodybackgroundPath.addLine(to: CGPoint(x: 427.9, y: 531))
        bodybackgroundPath.addCurve(to: CGPoint(x: 425.5, y: 500.5), controlPoint1: CGPoint(x: 427.4, y: 521.4), controlPoint2: CGPoint(x: 426.4, y: 507.6))
        bodybackgroundPath.addCurve(to: CGPoint(x: 423.9, y: 467.7), controlPoint1: CGPoint(x: 422.9, y: 478.3), controlPoint2: CGPoint(x: 422.8, y: 475.7))
        bodybackgroundPath.addCurve(to: CGPoint(x: 421.5, y: 441.4), controlPoint1: CGPoint(x: 424.9, y: 460.4), controlPoint2: CGPoint(x: 424.8, y: 458.6))
        bodybackgroundPath.addCurve(to: CGPoint(x: 418, y: 409.2), controlPoint1: CGPoint(x: 418.6, y: 425.9), controlPoint2: CGPoint(x: 418, y: 420.7))
        bodybackgroundPath.addCurve(to: CGPoint(x: 429.9, y: 361.1), controlPoint1: CGPoint(x: 418, y: 392.9), controlPoint2: CGPoint(x: 418.8, y: 389.5))
        bodybackgroundPath.addCurve(to: CGPoint(x: 441, y: 320.6), controlPoint1: CGPoint(x: 436.4, y: 344.2), controlPoint2: CGPoint(x: 441, y: 327.6))
        bodybackgroundPath.addCurve(to: CGPoint(x: 443.7, y: 319.2), controlPoint1: CGPoint(x: 441, y: 317.8), controlPoint2: CGPoint(x: 442.2, y: 317.2))
        bodybackgroundPath.addCurve(to: CGPoint(x: 448.5, y: 330.5), controlPoint1: CGPoint(x: 444.3, y: 319.9), controlPoint2: CGPoint(x: 446.4, y: 325))
        bodybackgroundPath.addCurve(to: CGPoint(x: 467.5, y: 366), controlPoint1: CGPoint(x: 454.6, y: 346.5), controlPoint2: CGPoint(x: 461.3, y: 359))
        bodybackgroundPath.addCurve(to: CGPoint(x: 474.7, y: 378), controlPoint1: CGPoint(x: 468.8, y: 367.4), controlPoint2: CGPoint(x: 472, y: 372.8))
        bodybackgroundPath.addCurve(to: CGPoint(x: 498.5, y: 416.5), controlPoint1: CGPoint(x: 479.4, y: 386.9), controlPoint2: CGPoint(x: 486, y: 397.7))
        bodybackgroundPath.addCurve(to: CGPoint(x: 538.5, y: 457.2), controlPoint1: CGPoint(x: 505.4, y: 426.8), controlPoint2: CGPoint(x: 517.2, y: 438.9))
        bodybackgroundPath.addCurve(to: CGPoint(x: 565.6, y: 481.7), controlPoint1: CGPoint(x: 547.9, y: 465.3), controlPoint2: CGPoint(x: 560.1, y: 476.3))
        bodybackgroundPath.addCurve(to: CGPoint(x: 577.4, y: 498.4), controlPoint1: CGPoint(x: 575.5, y: 491.3), controlPoint2: CGPoint(x: 575.8, y: 491.7))
        bodybackgroundPath.addCurve(to: CGPoint(x: 588.3, y: 520.2), controlPoint1: CGPoint(x: 579.5, y: 506.8), controlPoint2: CGPoint(x: 582.7, y: 513.3))
        bodybackgroundPath.addCurve(to: CGPoint(x: 596.7, y: 532.1), controlPoint1: CGPoint(x: 590.6, y: 523.1), controlPoint2: CGPoint(x: 594.4, y: 528.4))
        bodybackgroundPath.addCurve(to: CGPoint(x: 611.5, y: 544.5), controlPoint1: CGPoint(x: 603, y: 541.7), controlPoint2: CGPoint(x: 606, y: 544.3))
        bodybackgroundPath.addCurve(to: CGPoint(x: 616.4, y: 545.1), controlPoint1: CGPoint(x: 614, y: 544.6), controlPoint2: CGPoint(x: 616.2, y: 544.9))
        bodybackgroundPath.addCurve(to: CGPoint(x: 619.9, y: 550.2), controlPoint1: CGPoint(x: 616.5, y: 545.3), controlPoint2: CGPoint(x: 618.1, y: 547.6))
        bodybackgroundPath.addCurve(to: CGPoint(x: 630, y: 552.6), controlPoint1: CGPoint(x: 624.3, y: 556.7), controlPoint2: CGPoint(x: 630, y: 558.1))
        bodybackgroundPath.addCurve(to: CGPoint(x: 626.4, y: 542.4), controlPoint1: CGPoint(x: 630, y: 551.3), controlPoint2: CGPoint(x: 628.4, y: 546.8))
        bodybackgroundPath.addCurve(to: CGPoint(x: 623.1, y: 527.2), controlPoint1: CGPoint(x: 622.3, y: 533.7), controlPoint2: CGPoint(x: 620.8, y: 526.4))
        bodybackgroundPath.addCurve(to: CGPoint(x: 631, y: 540), controlPoint1: CGPoint(x: 623.9, y: 527.4), controlPoint2: CGPoint(x: 627.4, y: 533.2))
        bodybackgroundPath.addCurve(to: CGPoint(x: 640.2, y: 553.4), controlPoint1: CGPoint(x: 636.1, y: 549.8), controlPoint2: CGPoint(x: 638.1, y: 552.7))
        bodybackgroundPath.addCurve(to: CGPoint(x: 646, y: 549.9), controlPoint1: CGPoint(x: 643.3, y: 554.5), controlPoint2: CGPoint(x: 646, y: 552.9))
        bodybackgroundPath.addCurve(to: CGPoint(x: 641, y: 535.8), controlPoint1: CGPoint(x: 646, y: 548.9), controlPoint2: CGPoint(x: 643.8, y: 542.6))
        bodybackgroundPath.addCurve(to: CGPoint(x: 637.3, y: 521), controlPoint1: CGPoint(x: 635.7, y: 522.8), controlPoint2: CGPoint(x: 635.3, y: 521))
        bodybackgroundPath.addCurve(to: CGPoint(x: 646.9, y: 535.7), controlPoint1: CGPoint(x: 638.7, y: 521), controlPoint2: CGPoint(x: 642.4, y: 526.6))
        bodybackgroundPath.addCurve(to: CGPoint(x: 652.5, y: 542.6), controlPoint1: CGPoint(x: 649.2, y: 540.2), controlPoint2: CGPoint(x: 650.7, y: 542.1))
        bodybackgroundPath.addCurve(to: CGPoint(x: 658, y: 538.3), controlPoint1: CGPoint(x: 655.7, y: 543.4), controlPoint2: CGPoint(x: 658, y: 541.5))
        bodybackgroundPath.addCurve(to: CGPoint(x: 643.7, y: 507.6), controlPoint1: CGPoint(x: 658, y: 534.1), controlPoint2: CGPoint(x: 652, y: 521.2))
        bodybackgroundPath.addCurve(to: CGPoint(x: 635.6, y: 490), controlPoint1: CGPoint(x: 637, y: 496.6), controlPoint2: CGPoint(x: 635.7, y: 493.8))
        bodybackgroundPath.addCurve(to: CGPoint(x: 638.5, y: 485.7), controlPoint1: CGPoint(x: 635.5, y: 485.6), controlPoint2: CGPoint(x: 635.6, y: 485.5))
        bodybackgroundPath.addCurve(to: CGPoint(x: 645.7, y: 486.5), controlPoint1: CGPoint(x: 640.2, y: 485.7), controlPoint2: CGPoint(x: 643.4, y: 486.1))
        bodybackgroundPath.addCurve(to: CGPoint(x: 653, y: 482.5), controlPoint1: CGPoint(x: 650.6, y: 487.4), controlPoint2: CGPoint(x: 653, y: 486))
        bodybackgroundPath.addCurve(to: CGPoint(x: 636.7, y: 469.9), controlPoint1: CGPoint(x: 653, y: 479.3), controlPoint2: CGPoint(x: 648.6, y: 475.9))
        bodybackgroundPath.addCurve(to: CGPoint(x: 612.7, y: 465.4), controlPoint1: CGPoint(x: 625.8, y: 464.4), controlPoint2: CGPoint(x: 624.5, y: 464.2))
        bodybackgroundPath.addLine(to: CGPoint(x: 604.9, y: 466.2))
        bodybackgroundPath.addLine(to: CGPoint(x: 600.8, y: 461.9))
        bodybackgroundPath.addCurve(to: CGPoint(x: 574.6, y: 419.2), controlPoint1: CGPoint(x: 594.4, y: 455), controlPoint2: CGPoint(x: 587.2, y: 443.3))
        bodybackgroundPath.addCurve(to: CGPoint(x: 527.8, y: 352.5), controlPoint1: CGPoint(x: 558, y: 387.3), controlPoint2: CGPoint(x: 548.4, y: 373.7))
        bodybackgroundPath.addCurve(to: CGPoint(x: 514.5, y: 334), controlPoint1: CGPoint(x: 518, y: 342.4), controlPoint2: CGPoint(x: 516.9, y: 340.8))
        bodybackgroundPath.addCurve(to: CGPoint(x: 505.9, y: 313.9), controlPoint1: CGPoint(x: 513, y: 329.9), controlPoint2: CGPoint(x: 509.2, y: 320.8))
        bodybackgroundPath.addCurve(to: CGPoint(x: 496.4, y: 281.1), controlPoint1: CGPoint(x: 499.5, y: 300), controlPoint2: CGPoint(x: 498.8, y: 297.6))
        bodybackgroundPath.addCurve(to: CGPoint(x: 485, y: 241), controlPoint1: CGPoint(x: 494, y: 263.9), controlPoint2: CGPoint(x: 490.8, y: 252.6))
        bodybackgroundPath.addCurve(to: CGPoint(x: 458, y: 205.3), controlPoint1: CGPoint(x: 476.7, y: 224.4), controlPoint2: CGPoint(x: 471.5, y: 217.6))
        bodybackgroundPath.addCurve(to: CGPoint(x: 428.7, y: 186.7), controlPoint1: CGPoint(x: 445, y: 193.5), controlPoint2: CGPoint(x: 438.1, y: 189.1))
        bodybackgroundPath.addCurve(to: CGPoint(x: 409.7, y: 176.3), controlPoint1: CGPoint(x: 424.7, y: 185.6), controlPoint2: CGPoint(x: 419.1, y: 182.6))
        bodybackgroundPath.addCurve(to: CGPoint(x: 387.1, y: 162.5), controlPoint1: CGPoint(x: 402.5, y: 171.5), controlPoint2: CGPoint(x: 392.3, y: 165.2))
        bodybackgroundPath.addCurve(to: CGPoint(x: 367.1, y: 145.7), controlPoint1: CGPoint(x: 376.2, y: 156.7), controlPoint2: CGPoint(x: 368.5, y: 150.3))
        bodybackgroundPath.addCurve(to: CGPoint(x: 365.5, y: 133.4), controlPoint1: CGPoint(x: 366.6, y: 143.9), controlPoint2: CGPoint(x: 365.8, y: 138.4))
        bodybackgroundPath.addCurve(to: CGPoint(x: 366.9, y: 119.4), controlPoint1: CGPoint(x: 364.9, y: 125.5), controlPoint2: CGPoint(x: 365.1, y: 123.7))
        bodybackgroundPath.addCurve(to: CGPoint(x: 371, y: 98.3), controlPoint1: CGPoint(x: 369.8, y: 112.5), controlPoint2: CGPoint(x: 370.9, y: 106.6))
        bodybackgroundPath.addCurve(to: CGPoint(x: 372.4, y: 83.8), controlPoint1: CGPoint(x: 371, y: 94.4), controlPoint2: CGPoint(x: 371.6, y: 87.9))
        bodybackgroundPath.addCurve(to: CGPoint(x: 374.1, y: 49), controlPoint1: CGPoint(x: 374.8, y: 71.2), controlPoint2: CGPoint(x: 375.2, y: 64))
        bodybackgroundPath.addCurve(to: CGPoint(x: 367.1, y: 17.9), controlPoint1: CGPoint(x: 372.8, y: 30.5), controlPoint2: CGPoint(x: 371.7, y: 25.6))
        bodybackgroundPath.addCurve(to: CGPoint(x: 356.9, y: 7.8), controlPoint1: CGPoint(x: 364.1, y: 12.9), controlPoint2: CGPoint(x: 362, y: 10.9))
        bodybackgroundPath.addCurve(to: CGPoint(x: 345.5, y: 2.4), controlPoint1: CGPoint(x: 353.4, y: 5.7), controlPoint2: CGPoint(x: 348.3, y: 3.2))
        bodybackgroundPath.addCurve(to: CGPoint(x: 316.6, y: 1.5), controlPoint1: CGPoint(x: 338.3, y: 0.1), controlPoint2: CGPoint(x: 323.8, y: -0.3))
        bodybackgroundPath.close()
        
        return bodybackgroundPath
    }
    
//    var body: some View {
//        VStack {
//            if userState.authorization < 1 {
//                #if targetEnvironment(simulator)
//                SignInDevView()
//                #else
//                SignInView()
//                #endif
//            } else {
//                if route.current == .feed {
//                    VStack(spacing: 0) {
//                        VStack(alignment: .center) {
//                            Text("RYDEN")
//                                .foregroundColor(appColor)
//                                .fontWeight(.heavy)
//                                .font(.subheadline)
//
//                            Divider()
//                        }
//                            .background(Color.white)
//
//                        FeedView()
//
//                        VStack {
//                            Divider()
//                            HStack {
//                                Spacer()
//
//                                Button(action: { self.route.current = .editor }) {
//                                    ZStack {
//                                        Circle()
//                                            .stroke(appColor, lineWidth: 2)
//                                            .shadow(color: Color.gray.opacity(0.3), radius: 1.0)
//                                            .frame(width: 50, height: 50)
//
//                                        Circle()
//                                            .fill(appColor)
//                                            .shadow(color: Color.gray.opacity(0.3), radius: 1.0)
//                                            .frame(width: 20, height: 20)
//                                    }
//                                }
//
//                                Spacer()
//                            }
//                                .padding(.top, 5)
//                        }
//                            .background(Color.white)
//                    }
//                        .background(feedColor)
//                } else if route.current == .editor {
//                    EditableWorkoutView()
//                }
//            }
//        }
//    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let userState = UserState()
        
        return MainView()
            .environmentObject(RouteState())
            .environmentObject(UserState())
            .environmentObject(EditableWorkoutState())
            .environmentObject(MockWorkoutAPI(userState: userState) as WorkoutAPI)
            .environmentObject(MockExerciseAPI(userState: userState) as ExerciseAPI)
            .environmentObject(UserAPI())
    }
}
