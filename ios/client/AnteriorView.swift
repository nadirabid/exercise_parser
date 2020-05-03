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
    let activity: MuscleActivity
    let path: Path
    let absoluteSize: CGSize = CGSize(width: 658.16, height: 1125.9)
    
    init(_ muscle: Muscle, with activity: MuscleActivity = .none) {
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
        
        switch self.activity {
        case .primary:
            let colors = Gradient(colors: [secondaryAppColor, .yellow, appColor])
            radial = RadialGradient(
                gradient: colors,
                center: UnitPoint(x: bounds.midX / size.width, y: bounds.midY / size.height),
                startRadius: 0,
                endRadius: max(bounds.width, bounds.height)
            )
        case .secondary:
            let colors = Gradient(colors: [.green, .blue])
            radial = RadialGradient(
                gradient: colors,
                center: UnitPoint(x: bounds.midX / size.width, y: bounds.midY / size.height),
                startRadius: 0,
                endRadius: max(bounds.width, bounds.height)
            )
        case .none:
            radial = RadialGradient(gradient: Gradient(colors: [Color.clear]), center: UnitPoint.center, startRadius: 0, endRadius: 0)
        }
        
        return self.fill(radial)
    }
}

struct AnteriorView: View {
    var activatedPrimaryMuscles: [Muscle]
    var activiatedSecondaryMuscles: [Muscle]
    
    func muscleActivity(for muscle: Muscle) -> MuscleActivity {
        if activatedPrimaryMuscles.contains(muscle) {
            return .primary
        } else if activiatedSecondaryMuscles.contains(muscle) {
            return .secondary
        }

        return .none
    }
    
    var body: some View {
        return GeometryReader { (geometry: GeometryProxy) in
            ZStack {
                ZStack {
                    AnteriorShape(.Background)
                        .fill(appColor.opacity(0.2))
                        
                    AnteriorShape(.RectusAbdominis, with: self.muscleActivity(for: .RectusAbdominis))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.ExternalOblique, with: self.muscleActivity(for: .ExternalOblique))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.LatissimusDorsi, with: self.muscleActivity(for: .LatissimusDorsi))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.SerratusAnterior, with: self.muscleActivity(for: .SerratusAnterior))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.RectusFemoris, with: self.muscleActivity(for: .RectusFemoris))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.VastusLateralis, with: self.muscleActivity(for: .VastusMedialis))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.VastusMedialis, with: self.muscleActivity(for: .VastusMedialis))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.Peroneus, with: self.muscleActivity(for: .Peroneus))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.Soleus, with: self.muscleActivity(for: .Soleus))
                        .setGradient(geometry.size)
                }
                
                ZStack {
                    AnteriorShape(.TrapeziusUpperFibers, with: self.muscleActivity(for: .TrapeziusUpperFibers))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.PectoralisMajorClavicular, with: self.muscleActivity(for: .PectoralisMajorClavicular))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.PectoralisMajorSternal, with: self.muscleActivity(for: .PectoralisMajorSternal))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.Biceps, with: self.muscleActivity(for: .Biceps))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.FlexorCarpiRadialis, with: self.muscleActivity(for: .FlexorCarpiRadialis))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.FlexorCarpiUlnaris, with: self.muscleActivity(for: .FlexorCarpiUlnaris))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.FlexorDigitorumSuperficialis, with: self.muscleActivity(for: .FlexorDigitorumSuperficialis))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.Brachioradialis, with: self.muscleActivity(for: .Brachioradialis))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.Abductor, with: self.muscleActivity(for: .Abductor))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.AnteriorDeltoid, with: self.muscleActivity(for: .AnteriorDeltoid))
                        .setGradient(geometry.size)
                }
                
                ZStack {
                    AnteriorShape(.LateralDeltoid, with: self.muscleActivity(for: .LateralDeltoid))
                        .setGradient(geometry.size)
                    
                    AnteriorShape(.Body)
                        .stroke(secondaryAppColor.opacity(0.8), lineWidth: 0.3)
                }
            }
                .padding()
        }
    }
}

struct AnteriorView_Previews: PreviewProvider {
    static var previews: some View {
        AnteriorView(
            activatedPrimaryMuscles: [],
            activiatedSecondaryMuscles: []
        )
    }
}
