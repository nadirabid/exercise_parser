//
//  KinesiologyView.swift
//  client
//
//  Created by Nadir Muzaffar on 4/30/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct AnteriorShape: Shape {
    let muscle: Muscle
    let activity: MuscleUsage
    let path: Path
    let absoluteSize: CGSize = CGSize(width: 658.16, height: 1125.9)
    
    init(_ muscle: Muscle, with activity: MuscleUsage = .none) {
        self.muscle = muscle
        self.activity = activity
        self.path = AnteriorPath.from(muscle: muscle)
    }
    
    func path(in rect: CGRect) -> Path {
        let scaleX = rect.size.width / absoluteSize.width
        let scaleY = rect.size.height / absoluteSize.height
        
        let factor = min(scaleX, max(scaleY, 0.0))
        let center = CGPoint(x: absoluteSize.width / 2, y: absoluteSize.height / 2)
        
        var transform  = CGAffineTransform.identity
        
        transform = transform.concatenating(CGAffineTransform(translationX: -center.x, y: -center.y))
        transform = transform.concatenating(CGAffineTransform(scaleX: factor, y: factor))
        transform = transform.concatenating(CGAffineTransform(translationX: rect.midX, y: rect.midY))
        
        return path.applying(transform)
    }
    
    func setGradient(_ size: CGSize) -> some View {
        var radial: RadialGradient
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        
        let scaleX = rect.size.width / absoluteSize.width
        let scaleY = rect.size.height / absoluteSize.height
        
        let factor = min(scaleX, max(scaleY, 0.0))
        let center = CGPoint(x: absoluteSize.width / 2, y: absoluteSize.height / 2)
        
        var transform  = CGAffineTransform.identity
        
        transform = transform.concatenating(CGAffineTransform(translationX: -center.x, y: -center.y))
        transform = transform.concatenating(CGAffineTransform(scaleX: factor, y: factor))
        transform = transform.concatenating(CGAffineTransform(translationX: rect.midX, y: rect.midY))
        
        let bounds = self.path.boundingRect.applying(transform)
        let startRadius = 0.3 * max(bounds.width, bounds.height)
        
        switch self.activity {
        case .target:
            let colors = Gradient(colors: [secondaryAppColor.opacity(0.9), Color.yellow.opacity(0.9), appColor.opacity(0.9)])
            radial = RadialGradient(
                gradient: colors,
                center: UnitPoint(x: bounds.midX / size.width, y: bounds.midY / size.height),
                startRadius: startRadius,
                endRadius: max(bounds.width, bounds.height)
            )
        case .synergist:
            let colors = Gradient(colors: [Color.green.opacity(0.9), Color.blue.opacity(0.9), Color(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)).opacity(0.9)])
            radial = RadialGradient(
                gradient: colors,
                center: UnitPoint(x: bounds.midX / size.width, y: bounds.midY / size.height),
                startRadius: startRadius,
                endRadius: max(bounds.width, bounds.height)
            )
        case .stabilizer, .dynamicStabilizer, .antagonistStabilizer, .none:
            radial = RadialGradient(gradient: Gradient(colors: [Color.clear]), center: UnitPoint.center, startRadius: 0, endRadius: 0)
        }
        
        return self.fill(radial)
    }
}

struct AnteriorView: View {
    var activatedTargetMuscles: [MuscleActivation]
    var activatedSynergistMuscles: [MuscleActivation]
    
    func muscleUsage(for muscle: Muscle) -> MuscleUsage {
        if activatedTargetMuscles.contains(where: { $0.muscle == muscle } ) {
            return .target
        } else if activatedSynergistMuscles.contains(where: { $0.muscle == muscle } ) {
            return .synergist
        }

        return .none
    }
    
    var body: some View {
        return GeometryReader { (geometry: GeometryProxy) in
            ZStack {
                Color.clear
                
                ZStack {
                    AnteriorShape(.Background)
                        .fill(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                        
                    AnteriorShape(.RectusAbdominis, with: self.muscleUsage(for: .RectusAbdominis))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.ExternalOblique, with: self.muscleUsage(for: .ExternalOblique))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.LatissimusDorsi, with: self.muscleUsage(for: .LatissimusDorsi))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.SerratusAnterior, with: self.muscleUsage(for: .SerratusAnterior))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.RectusFemoris, with: self.muscleUsage(for: .RectusFemoris))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.VastusLateralis, with: self.muscleUsage(for: .VastusMedialis))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.VastusMedialis, with: self.muscleUsage(for: .VastusMedialis))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.Peroneus, with: self.muscleUsage(for: .Peroneus))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.Soleus, with: self.muscleUsage(for: .Soleus))
                        .setGradient(geometry.size)
                }
                
                ZStack {
                    AnteriorShape(.TrapeziusUpperFibers, with: self.muscleUsage(for: .TrapeziusUpperFibers))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.PectoralisMajorClavicular, with: self.muscleUsage(for: .PectoralisMajorClavicular))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.PectoralisMajorSternal, with: self.muscleUsage(for: .PectoralisMajorSternal))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.Biceps, with: self.muscleUsage(for: .Biceps))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.FlexorCarpiRadialis, with: self.muscleUsage(for: .FlexorCarpiRadialis))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.FlexorCarpiUlnaris, with: self.muscleUsage(for: .FlexorCarpiUlnaris))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.FlexorDigitorumSuperficialis, with: self.muscleUsage(for: .FlexorDigitorumSuperficialis))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.Brachioradialis, with: self.muscleUsage(for: .Brachioradialis))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.Abductor, with: self.muscleUsage(for: .Abductor))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.AnteriorDeltoid, with: self.muscleUsage(for: .AnteriorDeltoid))
                        .setGradient(geometry.size)
                }
                
                ZStack {
                    AnteriorShape(.LateralDeltoid, with: self.muscleUsage(for: .LateralDeltoid))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.Body)
                        .stroke(Color(#colorLiteral(red: 0.9134874683, green: 0.9134874683, blue: 0.9134874683, alpha: 1)), lineWidth: 0.7)
                }
            }
                .padding()
        }
    }
}

struct AnteriorView_Previews: PreviewProvider {
    static var previews: some View {
        AnteriorView(
            activatedTargetMuscles: [],
            activatedSynergistMuscles: []
        )
    }
}
