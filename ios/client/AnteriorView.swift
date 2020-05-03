//
//  KinesiologyView.swift
//  client
//
//  Created by Nadir Muzaffar on 4/30/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct AnteriorShape: Shape {
    let path: Path
    let absoluteSize: CGSize = CGSize(width: 658.16, height: 1125.9)
    
    init(_ path: Path) {
        self.path = path
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
    
    func setGradient(_ activity: MuscleActivity, _ size: CGSize) -> some View {
        var radial: RadialGradient
        
        switch activity {
        case .primary, .secondary:
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
            
            let colors = Gradient(colors: [.red, .yellow, .orange])
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
    
    func getMuscleActivity(for muscle: Muscle) -> MuscleActivity {
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
                    AnteriorShape(Path(AnteriorPath.bodybackgroundPath().cgPath))
                        .fill(appColor.opacity(0.2))
                        
                    AnteriorShape(AnteriorPath.from(muscle: .RectusAbdominis))
                        .setGradient(self.getMuscleActivity(for: .RectusAbdominis), geometry.size)
                    
                    AnteriorShape(AnteriorPath.from(muscle: .ExternalOblique))
                        .setGradient(self.getMuscleActivity(for: .ExternalOblique), geometry.size)
                    
                    AnteriorShape(AnteriorPath.from(muscle: .LatissimusDorsi))
                        .setGradient(self.getMuscleActivity(for: .LatissimusDorsi), geometry.size)
                    
                    AnteriorShape(AnteriorPath.from(muscle: .SerratusAnterior))
                        .setGradient(self.getMuscleActivity(for: .SerratusAnterior), geometry.size)
                    
                    AnteriorShape(AnteriorPath.from(muscle: .RectusFemoris))
                        .setGradient(self.getMuscleActivity(for: .RectusFemoris), geometry.size)
                    
                    AnteriorShape(AnteriorPath.from(muscle: .VastusLateralis))
                        .setGradient(self.getMuscleActivity(for: .VastusMedialis), geometry.size)
                    
                    AnteriorShape(AnteriorPath.from(muscle: .VastusMedialis))
                        .setGradient(self.getMuscleActivity(for: .VastusMedialis), geometry.size)
                    
                    AnteriorShape(AnteriorPath.from(muscle: .Peroneus))
                        .setGradient(self.getMuscleActivity(for: .Peroneus), geometry.size)
                    
                    AnteriorShape(AnteriorPath.from(muscle: .Soleus))
                        .setGradient(self.getMuscleActivity(for: .Soleus), geometry.size)
                }
                
                ZStack {
                    AnteriorShape(AnteriorPath.from(muscle: .TrapeziusUpperFibers))
                        .setGradient(self.getMuscleActivity(for: .TrapeziusUpperFibers), geometry.size)
                    
                    AnteriorShape(AnteriorPath.from(muscle: .PectoralisMajorClavicular))
                        .setGradient(self.getMuscleActivity(for: .PectoralisMajorClavicular), geometry.size)
                    
                    AnteriorShape(AnteriorPath.from(muscle: .PectoralisMajorSternal))
                        .setGradient(self.getMuscleActivity(for: .PectoralisMajorSternal), geometry.size)
                    
                    AnteriorShape(AnteriorPath.from(muscle: .Biceps))
                        .setGradient(self.getMuscleActivity(for: .Biceps), geometry.size)
                    
                    AnteriorShape(AnteriorPath.from(muscle: .FlexorCarpiRadialis))
                        .setGradient(self.getMuscleActivity(for: .FlexorCarpiRadialis), geometry.size)
                    
                    AnteriorShape(AnteriorPath.from(muscle: .FlexorCarpiUlnaris))
                        .setGradient(self.getMuscleActivity(for: .FlexorCarpiUlnaris), geometry.size)
                    
                    AnteriorShape(AnteriorPath.from(muscle: .FlexorDigitorumSuperficialis))
                        .setGradient(self.getMuscleActivity(for: .FlexorDigitorumSuperficialis), geometry.size)
                    
                    AnteriorShape(AnteriorPath.from(muscle: .Brachioradialis))
                        .setGradient(self.getMuscleActivity(for: .Brachioradialis), geometry.size)
                    
                    AnteriorShape(AnteriorPath.from(muscle: .Abductor))
                        .setGradient(self.getMuscleActivity(for: .Abductor), geometry.size)
                    
                    AnteriorShape(AnteriorPath.from(muscle: .AnteriorDeltoid))
                        .setGradient(self.getMuscleActivity(for: .AnteriorDeltoid), geometry.size)
                }
                
                ZStack {
                    AnteriorShape(AnteriorPath.from(muscle: .LateralDeltoid))
                        .setGradient(self.getMuscleActivity(for: .LateralDeltoid), geometry.size)
                    
                    AnteriorShape(Path(AnteriorPath.bodyPath().cgPath))
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
