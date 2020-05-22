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
    let usage: MuscleUsage
    let activiation: Double
    let path: Path
    
    static let absoluteSize: CGSize = CGSize(width: 658.16, height: 1125.9)
    
    init(_ muscle: Muscle, _ activation: Double = 0, with usage: MuscleUsage = .none) {
        self.muscle = muscle
        self.usage = usage
        self.activiation = activation
        self.path = AnteriorPath.from(muscle: muscle)
    }
    
    func path(in rect: CGRect) -> Path {
        let scaleX = rect.size.width / AnteriorShape.absoluteSize.width
        let scaleY = rect.size.height / AnteriorShape.absoluteSize.height
        
        let factor = min(scaleX, max(scaleY, 0.0))
        let center = CGPoint(x: AnteriorShape.absoluteSize.width / 2, y: AnteriorShape.absoluteSize.height / 2)
        
        var transform  = CGAffineTransform.identity
        
        transform = transform.concatenating(CGAffineTransform(translationX: -center.x, y: -center.y))
        transform = transform.concatenating(CGAffineTransform(scaleX: factor, y: factor))
        transform = transform.concatenating(CGAffineTransform(translationX: rect.midX, y: rect.midY))
        
        return path.applying(transform)
    }
    
    func setGradient(_ size: CGSize) -> some View {
        var radial: RadialGradient
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        
        let scaleX = rect.size.width / AnteriorShape.absoluteSize.width
        let scaleY = rect.size.height / AnteriorShape.absoluteSize.height
        
        let factor = min(scaleX, max(scaleY, 0.0))
        let center = CGPoint(x: AnteriorShape.absoluteSize.width / 2, y: AnteriorShape.absoluteSize.height / 2)
        
        var transform  = CGAffineTransform.identity
        
        transform = transform.concatenating(CGAffineTransform(translationX: -center.x, y: -center.y))
        transform = transform.concatenating(CGAffineTransform(scaleX: factor, y: factor))
        transform = transform.concatenating(CGAffineTransform(translationX: rect.midX, y: rect.midY))
        
        let bounds = self.path.boundingRect.applying(transform)
        let radialCenter = UnitPoint(x: bounds.midX / size.width, y: bounds.midY / size.height)
        let startRadius = 0.3 * max(bounds.width, bounds.height)
        let endRadius = max(bounds.width, bounds.height)
        
        switch self.usage {
        case .target:
            let opacity = self.activiation
            let colors = Gradient(colors: [secondaryAppColor.opacity(opacity), Color.yellow.opacity(opacity), appColor.opacity(opacity)])
            radial = RadialGradient(
                gradient: colors,
                center: radialCenter,
                startRadius: startRadius,
                endRadius: endRadius
            )
        case .synergist:
            let opacity = self.activiation * 0.9
            let colors = Gradient(colors: [Color.green.opacity(opacity), Color.blue.opacity(opacity), Color(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)).opacity(opacity)])
            radial = RadialGradient(
                gradient: colors,
                center: radialCenter,
                startRadius: startRadius,
                endRadius: endRadius
            )
        case .dynamicArticulation:
            let opacity = self.activiation * 0.5
            let colors = Gradient(colors: [secondaryAppColor.opacity(opacity), Color.yellow.opacity(opacity), appColor.opacity(opacity)])
            radial = RadialGradient(
                gradient: colors,
                center: radialCenter,
                startRadius: startRadius,
                endRadius: endRadius
            )
        case .stabilizer, .dynamicStabilizer, .antagonistStabilizer, .staticArticulation, .none:
            radial = RadialGradient(gradient: Gradient(colors: [Color.clear]), center: UnitPoint.center, startRadius: 0, endRadius: 0)
        }
        
        return self.fill(radial)
    }
    
    static func calculateSize(_ size: CGSize) -> CGSize {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        
        let scaleX = rect.size.width / AnteriorShape.absoluteSize.width
        let scaleY = rect.size.height / AnteriorShape.absoluteSize.height
        
        let factor = min(scaleX, max(scaleY, 0.0))
        
        return CGSize(width: AnteriorShape.absoluteSize.width*factor, height: AnteriorShape.absoluteSize.height*factor)
    }
}

struct AnteriorView: View {
    var activatedTargetMuscles: [MuscleActivation]
    var activatedSynergistMuscles: [MuscleActivation]
    var activatedDynamicArticulationMuscles: [MuscleActivation]
    
    func muscleUsage(for muscle: Muscle) -> MuscleUsage {
        if activatedTargetMuscles.contains(where: { $0.muscle == muscle } ) {
            return .target
        } else if activatedSynergistMuscles.contains(where: { $0.muscle == muscle } ) {
            return .synergist
        } else if activatedDynamicArticulationMuscles.contains(where: { $0.muscle == muscle }) {
            return .dynamicArticulation
        }

        return .none
    }
    
    func muscleActivation(for muscle: Muscle) -> Double {
        if let activation = activatedTargetMuscles.first(where: { $0.muscle == muscle }) {
            return activation.activation
        } else if let activation = activatedSynergistMuscles.first(where: { $0.muscle == muscle }) {
            return activation.activation
        } else if let activation = activatedDynamicArticulationMuscles.first(where: { $0.muscle == muscle }) {
            return activation.activation
        }
        
        return 0
    }
    
    var body: some View {
        GeometryReader { (geometry: GeometryProxy) in
            ZStack {
                ZStack {
                    AnteriorShape(.Background)
                        .fill(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                        
                    AnteriorShape(.RectusAbdominis, self.muscleActivation(for: .RectusAbdominis), with: self.muscleUsage(for: .RectusAbdominis))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.ExternalOblique, self.muscleActivation(for: .ExternalOblique), with: self.muscleUsage(for: .ExternalOblique))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.LatissimusDorsi, self.muscleActivation(for: .LatissimusDorsi), with: self.muscleUsage(for: .LatissimusDorsi))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.SerratusAnterior, self.muscleActivation(for: .SerratusAnterior), with: self.muscleUsage(for: .SerratusAnterior))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.RectusFemoris, self.muscleActivation(for: .RectusFemoris), with: self.muscleUsage(for: .RectusFemoris))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.VastusLateralis, self.muscleActivation(for: .VastusLateralis), with: self.muscleUsage(for: .VastusMedialis))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.VastusMedialis, self.muscleActivation(for: .VastusMedialis), with: self.muscleUsage(for: .VastusMedialis))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.Peroneus, self.muscleActivation(for: .Peroneus), with: self.muscleUsage(for: .Peroneus))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.Soleus, self.muscleActivation(for: .Soleus), with: self.muscleUsage(for: .Soleus))
                        .setGradient(geometry.size)
                }
                
                ZStack {
                    AnteriorShape(.TrapeziusUpperFibers, self.muscleActivation(for: .TrapeziusUpperFibers), with: self.muscleUsage(for: .TrapeziusUpperFibers))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.PectoralisMajorClavicular, self.muscleActivation(for: .PectoralisMajorClavicular), with: self.muscleUsage(for: .PectoralisMajorClavicular))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.PectoralisMajorSternal, self.muscleActivation(for: .PectoralisMajorSternal), with: self.muscleUsage(for: .PectoralisMajorSternal))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.Biceps, self.muscleActivation(for: .Biceps), with: self.muscleUsage(for: .Biceps))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.FlexorCarpiRadialis, self.muscleActivation(for: .FlexorCarpiRadialis), with: self.muscleUsage(for: .FlexorCarpiRadialis))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.FlexorCarpiUlnaris, self.muscleActivation(for: .FlexorCarpiUlnaris), with: self.muscleUsage(for: .FlexorCarpiUlnaris))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.FlexorDigitorumSuperficialis, self.muscleActivation(for: .FlexorDigitorumSuperficialis), with: self.muscleUsage(for: .FlexorDigitorumSuperficialis))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.Brachioradialis, self.muscleActivation(for: .Brachioradialis), with: self.muscleUsage(for: .Brachioradialis))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.Abductor, self.muscleActivation(for: .Abductor), with: self.muscleUsage(for: .Abductor))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.AnteriorDeltoid, self.muscleActivation(for: .AnteriorDeltoid), with: self.muscleUsage(for: .AnteriorDeltoid))
                        .setGradient(geometry.size)
                }
                
                ZStack {
                    AnteriorShape(.LateralDeltoid, self.muscleActivation(for: .LateralDeltoid), with: self.muscleUsage(for: .LateralDeltoid))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.Body)
                        .stroke(Color(#colorLiteral(red: 0.9134874683, green: 0.9134874683, blue: 0.9134874683, alpha: 1)), lineWidth: 0.7)
                }
            }
        }
    }
}

struct AnteriorView_Previews: PreviewProvider {
    static var previews: some View {
        AnteriorView(
            activatedTargetMuscles: [],
            activatedSynergistMuscles: [],
            activatedDynamicArticulationMuscles: []
        )
    }
}
