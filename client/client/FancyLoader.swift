//
//  FancyLoader.swift
//  client
//
//  Created by Nadir Muzaffar on 3/20/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct FancyLoader: View {
    @State private var oneBounce = false
    @State private var twoBounce = false
    @State private var threeBounce = false
    @State private var fourBounce = false
    @State private var fiveBounce = false
    private let radius = CGFloat(6.0)
    private let radiusGrowth = CGFloat(0.05)
    private let bounceHeight = CGFloat(2)
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Circle()
                    .frame(
                        width: oneBounce ? radius : radius * (1 + radiusGrowth),
                        height: radius
                    )
                    .foregroundColor(oneBounce ?
                        Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)) :
                        Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1))
                    )
                    .offset(y: oneBounce ? 0 : bounceHeight)
                    .animation(
                        Animation.interpolatingSpring(stiffness: 200, damping: 3)
                            .repeatForever(autoreverses: false)
                            .delay(0.01)
                            .speed(0.5)
                    )
                    .onAppear() { self.oneBounce.toggle() }
                
                Circle()
                    .frame(
                        width: twoBounce ? radius : radius * (1 + radiusGrowth),
                        height: radius
                    )
                    .foregroundColor(twoBounce ?
                        Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)) :
                        Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1))
                    )
                    .offset(y: twoBounce ? 0 : bounceHeight)
                    .animation(
                        Animation.interpolatingSpring(stiffness: 200, damping: 3)
                            .repeatForever(autoreverses: false)
                            .delay(0.04)
                            .speed(0.5)
                    )
                    .onAppear() { self.twoBounce.toggle() }
                
                Circle()
                    .frame(
                        width: threeBounce ? radius : radius * (1 + radiusGrowth),
                        height: radius
                    )
                    .foregroundColor(threeBounce ?
                        Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)) :
                        Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1))
                    )
                    .offset(y: threeBounce ? 0 : bounceHeight)
                    .animation(
                        Animation.interpolatingSpring(stiffness: 200, damping: 3)
                            .repeatForever(autoreverses: false)
                            .delay(0.07)
                            .speed(0.5)
                    )
                    .onAppear() { self.threeBounce.toggle() }
                
                Circle()
                    .frame(
                        width: fourBounce ? radius : radius * (1 + radiusGrowth),
                        height: radius
                    )
                    .foregroundColor(fourBounce ?
                        Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)) :
                        Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1))
                    )
                    .offset(y: fourBounce ? 0 : bounceHeight)
                    .animation(
                        Animation.interpolatingSpring(stiffness: 200, damping: 3)
                            .repeatForever(autoreverses: false)
                            .delay(0.10)
                            .speed(0.5)
                    )
                    .onAppear() { self.fourBounce.toggle() }
            }
        }
    }
}

struct FancyLoader_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            FancyLoader()
            FancyLoader()
            FancyLoader()
            Spacer()
        }
    }
}
