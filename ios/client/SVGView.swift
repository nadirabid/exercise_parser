//
//  SVGView.swift
//  client
//
//  Created by Nadir Muzaffar on 4/28/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

import SwiftUI
import SwiftSVG

struct TestController: UIViewRepresentable {
    var svgNameT: String
    var sizeT: CGSize

    private var svgLayer: SVGLayer

    init(svgName: String, size: CGSize) {
        let sockPuppet = "M75 0 l75 200 L0 200 Z"

        svgNameT = svgName
        sizeT = size
        svgLayer = SVGLayer(pathString: sockPuppet)
    }

    func makeUIView(context: Context) -> UIView {
        let returnView = UIView()
        returnView.layer.addSublayer(svgLayer)

        svgLayer.resizeToFit(returnView.bounds)

        //sockPuppetSVG.resizeToFit(CGRect(x: size.width / 2, y: size.height / 2, width: size.width, height: size.height))
        return returnView
    }

    func updateUIView(_ view: UIView, context: Context) {
        svgLayer.fillColor = UIColor.red.cgColor
        //svgLayer.resizeToFit(view.bounds)
    }
}

//class MyLayout: ContentLayout {
//
//    override func layout(rect: Rect, into sizeToFitIn: Size) -> Transform {
//        // scale scene to fit view bounds
//        return Transform.scale(sx: sizeToFitIn.w / rect.w, sy: sizeToFitIn.h / rect.h)
//            // rotate scene upside down around the center
//            .rotate(angle: .pi, x: rect.center().x, y: rect.center().y)
//    }
//}
//
//struct SVGImage: UIViewRepresentable {
//    var svgName: String
//    let size: CGSize
//
//    func makeUIView(context: Context) -> MacawView {
//        let node = try! SVGParser.parse(resource: svgName)
//
//        let test = node.nodeBy(tag: "FMA:9628")
//        let e = Effect(input: test?.effect)
//        test?.effect = e.setColor(to: Color.blue)
//
//        let svgView = MacawView(node: node, frame: UIScreen.main.bounds)
//        svgView.backgroundColor = UIColor.clear
//        svgView.layer.borderWidth = 11.0
//        svgView.layer.borderColor = UIColor.blue.cgColor
//        svgView.contentMode = .scaleAspectFit
//        //svgView.contentLayout = MyLayout()
//
//        return svgView
//    }
//
//    func updateUIView(_ uiView: MacawView, context: Context) {
//        //uiView.sizeThatFits(size)
//    }
//}

struct MacawSVGView: View {
    var body: some View {
        GeometryReader { (geometry: GeometryProxy) in
            TestController(svgName: "Anterior", size: geometry.size)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .border(Color.red)
        }
    }
}
