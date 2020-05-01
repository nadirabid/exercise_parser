//
//  PosteriorView.swift
//  client
//
//  Created by Nadir Muzaffar on 5/1/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct PosteriorShape: Shape {
    let path: UIBezierPath
    let absoluteSize: CGSize = CGSize(width: 480.75, height: 845.55)
    
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

struct PosteriorView: View {
    var body: some View {
        VStack(alignment: .center) {
        GeometryReader { geometry in
            ZStack {
                PosteriorShape(PosteriorBezierPath.bodybackgroundPath())
                PosteriorShape(PosteriorBezierPath.fma13335Path())
                PosteriorShape(PosteriorBezierPath.fma13357Path())
                PosteriorShape(PosteriorBezierPath.fma13379Path())
                PosteriorShape(PosteriorBezierPath.fma22314Path())
                PosteriorShape(PosteriorBezierPath.fma22315Path())
                PosteriorShape(PosteriorBezierPath.fma22356Path())
                PosteriorShape(PosteriorBezierPath.fma22357Path())
                PosteriorShape(PosteriorBezierPath.fma32546Path())
                PosteriorShape(PosteriorBezierPath.fma32549Path())
            }
            .border(Color.blue)
            
            ZStack {
                PosteriorShape(PosteriorBezierPath.fma32555Path())
                PosteriorShape(PosteriorBezierPath.fma32556Path())
                PosteriorShape(PosteriorBezierPath.fma32557Path())
                PosteriorShape(PosteriorBezierPath.fma37692Path())
                PosteriorShape(PosteriorBezierPath.fma37694Path())
                PosteriorShape(PosteriorBezierPath.fma37704Path())
                PosteriorShape(PosteriorBezierPath.fma38465Path())
                PosteriorShape(PosteriorBezierPath.fma38485Path())
                PosteriorShape(PosteriorBezierPath.fma38500Path())
                PosteriorShape(PosteriorBezierPath.fma38506Path())
            }
            
            ZStack {
                PosteriorShape(PosteriorBezierPath.fma38518Path())
                PosteriorShape(PosteriorBezierPath.fma38521Path())
                PosteriorShape(PosteriorBezierPath.fma45956Path())
                PosteriorShape(PosteriorBezierPath.fma45959Path())
                PosteriorShape(PosteriorBezierPath.fma51048Path())
                PosteriorShape(PosteriorBezierPath.fma71302Path())
                PosteriorShape(PosteriorBezierPath.fma74998Path())
                PosteriorShape(PosteriorBezierPath.fma83006Path())
                PosteriorShape(PosteriorBezierPath.fma83007Path())
                PosteriorShape(PosteriorBezierPath.bodyPath())
            }
        }
            .padding()
        }
    }
}

struct PosteriorView_Previews: PreviewProvider {
    static var previews: some View {
        PosteriorView()
    }
}
