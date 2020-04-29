//
//  SVGView.swift
//  client
//
//  Created by Nadir Muzaffar on 4/28/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

import SwiftUI
import Macaw

struct SVGViewController: UIViewRepresentable {
    
    func makeUIView(context: Context) -> MacawView {
        let rootNode = try! SVGParser.parse(resource: "Assets/Anterior", ofType: "svg")
        let view = MacawView(node: rootNode, frame: CGRect.zero)
        return view
    }
    
    func updateUIView(_ activityIndicator: MacawView, context: Context) {
        
    }
}

struct MacawSVGView: View {
    var body: some View {
        GeometryReader { geometry in
            SVGViewController()
                .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct MacawSVGView_Previews: PreviewProvider {
    static var previews: some View {
        MacawSVGView()
    }
}

struct SVGView_Previews: PreviewProvider {
    static var previews: some View {
        MacawSVGView()
    }
}
