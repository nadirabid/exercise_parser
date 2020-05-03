//
//  PosteriorView.swift
//  client
//
//  Created by Nadir Muzaffar on 5/1/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct PosteriorShape: Shape {
    let muscle: Muscle
    let activity: MuscleActivity
    let path: Path
    let absoluteSize: CGSize = CGSize(width: 480.75, height: 845.55)
    
    init(_ muscle: Muscle, with activity: MuscleActivity = .none) {
        self.muscle = muscle
        self.activity = activity
        self.path = PosteriorPath.from(muscle: muscle)
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

struct PosteriorView: View {
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
        GeometryReader { geometry in
            ZStack {
                ZStack {
                    PosteriorShape(.Background)
                        .fill(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                    
                    PosteriorShape(.ExternalOblique, with: self.muscleActivity(for: .ExternalOblique))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.LatissimusDorsi, with: self.muscleActivity(for: .LatissimusDorsi))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.RhomboidMajor, with: self.muscleActivity(for: .RhomboidMajor))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.GluteusMaximus, with: self.muscleActivity(for: .GluteusMaximus))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.GluteusMedius, with: self.muscleActivity(for: .GluteusMedius))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.BicepsFemoris, with: self.muscleActivity(for: .BicepsFemoris))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.Semitendinosus, with: self.muscleActivity(for: .Semitendinosus))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.Infraspinatus, with: self.muscleActivity(for: .Infraspinatus))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.TeresMajor, with: self.muscleActivity(for: .TeresMajor))
                        .setGradient(geometry.size)
                }
                
                ZStack {
                    PosteriorShape(.TrapeziusLowerFibers, with: self.muscleActivity(for: .TrapeziusLowerFibers))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.TrapeziusMiddleFibers, with: self.muscleActivity(for: .TrapeziusMiddleFibers))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.TrapeziusUpperFibers, with: self.muscleActivity(for: .TrapeziusUpperFibers))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.TricepsLongHead, with: self.muscleActivity(for: .TricepsLongHead))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.TricepsLateralHead, with: self.muscleActivity(for: .TricepsLateralHead))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.Anconeus, with: self.muscleActivity(for: .Anconeus))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.FlexorCarpiUlnaris, with: self.muscleActivity(for: .FlexorCarpiUlnaris))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.Brachioradialis, with: self.muscleActivity(for: .Brachioradialis))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.ExtensorDigitorum, with: self.muscleActivity(for: .ExtensorDigitorum))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.ExtensorCarpiUlnaris, with: self.muscleActivity(for: .ExtensorCarpiUlnaris))
                        .setGradient(geometry.size)
                }
                
                ZStack {
                    PosteriorShape(.ExtensorPollicisBrevis, with: self.muscleActivity(for: .ExtensorPollicisBrevis))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.EntensorPollicisLongus, with: self.muscleActivity(for: .EntensorPollicisLongus))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.GastrocnemiusMedialHead, with: self.muscleActivity(for: .GastrocnemiusMedialHead))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.GastrocnemiusLateralHead, with: self.muscleActivity(for: .GastrocnemiusLateralHead))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.IliotibialBand, with: self.muscleActivity(for: .IliotibialBand))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.ErectorSpinae, with: self.muscleActivity(for: .ErectorSpinae))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.Abductor, with: self.muscleActivity(for: .Abductor))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.LateralDeltoid, with: self.muscleActivity(for: .LateralDeltoid))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.PosteriorDeltoid, with: self.muscleActivity(for: .PosteriorDeltoid))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.Body)
                        .stroke(Color(#colorLiteral(red: 0.9134874683, green: 0.9134874683, blue: 0.9134874683, alpha: 1)), lineWidth: 0.5)
                }
            }
        }
            .padding()
    }
}

struct PosteriorView_Previews: PreviewProvider {
    static var previews: some View {
        PosteriorView(
            activatedPrimaryMuscles: [],
            activiatedSecondaryMuscles: []
        )
    }
}
