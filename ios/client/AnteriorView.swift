//
//  KinesiologyView.swift
//  client
//
//  Created by Nadir Muzaffar on 4/30/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct AnteriorShape: Shape {
    let path: UIBezierPath
    let absoluteSize: CGSize = CGSize(width: 658.16, height: 1125.9)
    
    init(_ path: UIBezierPath) {
        self.path = path
    }
    
    func path(in rect: CGRect) -> Path {
        let p = Path(path.cgPath)
        
        let scaleX = rect.size.width / absoluteSize.width
        let scaleY = rect.size.height / absoluteSize.height
        
        let factor = min(scaleX, max(scaleY, 0.0))
        let center = CGPoint(x: absoluteSize.width / 2, y: absoluteSize.height / 2)
        
        var transform  = CGAffineTransform.identity
        
        transform = transform.concatenating(CGAffineTransform(translationX: -center.x, y: -center.y))
        transform = transform.concatenating(CGAffineTransform(scaleX: factor, y: factor))
        transform = transform.concatenating(CGAffineTransform(translationX: rect.midX, y: rect.midY))
        
        return p.applying(transform)
    }
}

struct AnteriorView: View {
    let gradient = LinearGradient(
        gradient: Gradient(colors: [secondaryAppColor, feedColor]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ZStack {
                    AnteriorShape(AnteriorBezierPath.bodybackgroundPath()).fill(Color.clear)
                    AnteriorShape(AnteriorBezierPath.fma9628Path()).fill(Color.clear)
                    AnteriorShape(AnteriorBezierPath.fma13335Path()).fill(Color.clear)
                    AnteriorShape(AnteriorBezierPath.fma13357Path()).fill(Color.clear)
                    AnteriorShape(AnteriorBezierPath.fma13397Path()).fill(Color.clear)
                    AnteriorShape(AnteriorBezierPath.fma22430Path()).fill(Color.clear)
                    AnteriorShape(AnteriorBezierPath.fma22431Path()).fill(Color.clear)
                    AnteriorShape(AnteriorBezierPath.fma22432Path()).fill(Color.clear)
                    AnteriorShape(AnteriorBezierPath.fma22538Path()).fill(Color.clear)
                    AnteriorShape(AnteriorBezierPath.fma22542Path()).fill(Color.clear)
                }
                ZStack {
                    AnteriorShape(AnteriorBezierPath.fma22430Path()).fill(Color.clear)
                    AnteriorShape(AnteriorBezierPath.fma22431Path()).fill(Color.clear)
                    AnteriorShape(AnteriorBezierPath.fma22432Path()).fill(Color.clear)
                    AnteriorShape(AnteriorBezierPath.fma22538Path()).fill(Color.clear)
                    AnteriorShape(AnteriorBezierPath.fma22542Path()).fill(Color.clear)
                    AnteriorShape(AnteriorBezierPath.fma32557Path()).fill(Color.clear)
                    AnteriorShape(AnteriorBezierPath.fma34687Path()).fill(Color.clear)
                    AnteriorShape(AnteriorBezierPath.fma34696Path()).fill(Color.clear)
                    AnteriorShape(AnteriorBezierPath.fma37670Path()).fill(Color.clear)
                    AnteriorShape(AnteriorBezierPath.fma38459Path()).fill(Color.clear)
                }
                ZStack {
                    AnteriorShape(AnteriorBezierPath.fma38465Path()).fill(Color.clear)
                    AnteriorShape(AnteriorBezierPath.fma38469Path()).fill(Color.clear)
                    AnteriorShape(AnteriorBezierPath.fma38485Path()).fill(Color.clear)
                    AnteriorShape(AnteriorBezierPath.fma74998Path()).fill(Color.clear)
                    AnteriorShape(AnteriorBezierPath.fma83003Path()).fill(Color.clear)
                    AnteriorShape(AnteriorBezierPath.fma83006Path()).fill(Color.clear)
                    AnteriorShape(AnteriorBezierPath.bodyPath()).fill(secondaryAppColor)
                }
            }
                .padding()
        }
    }
}

struct AnteriorView_Previews: PreviewProvider {
    static var previews: some View {
        AnteriorView()
    }
}
