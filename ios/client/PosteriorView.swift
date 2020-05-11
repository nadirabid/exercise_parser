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
    let activity: MuscleUsage
    let path: Path
    let absoluteSize: CGSize = CGSize(width: 480.75, height: 845.55)
    
    init(_ muscle: Muscle, with activity: MuscleUsage = .none) {
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

struct PosteriorView: View {
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
        GeometryReader { geometry in
            ZStack {
                ZStack {
                    PosteriorShape(.Background)
                        .fill(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                    
                    PosteriorShape(.ExternalOblique, with: self.muscleUsage(for: .ExternalOblique))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.LatissimusDorsi, with: self.muscleUsage(for: .LatissimusDorsi))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.RhomboidMajor, with: self.muscleUsage(for: .RhomboidMajor))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.GluteusMaximus, with: self.muscleUsage(for: .GluteusMaximus))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.GluteusMedius, with: self.muscleUsage(for: .GluteusMedius))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.BicepsFemoris, with: self.muscleUsage(for: .BicepsFemoris))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.Semitendinosus, with: self.muscleUsage(for: .Semitendinosus))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.Infraspinatus, with: self.muscleUsage(for: .Infraspinatus))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.TeresMajor, with: self.muscleUsage(for: .TeresMajor))
                        .setGradient(geometry.size)
                }
                
                ZStack {
                    PosteriorShape(.TrapeziusLowerFibers, with: self.muscleUsage(for: .TrapeziusLowerFibers))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.TrapeziusMiddleFibers, with: self.muscleUsage(for: .TrapeziusMiddleFibers))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.TrapeziusUpperFibers, with: self.muscleUsage(for: .TrapeziusUpperFibers))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.TricepsLongHead, with: self.muscleUsage(for: .TricepsLongHead))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.TricepsLateralHead, with: self.muscleUsage(for: .TricepsLateralHead))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.Anconeus, with: self.muscleUsage(for: .Anconeus))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.FlexorCarpiUlnaris, with: self.muscleUsage(for: .FlexorCarpiUlnaris))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.Brachioradialis, with: self.muscleUsage(for: .Brachioradialis))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.ExtensorDigitorum, with: self.muscleUsage(for: .ExtensorDigitorum))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.ExtensorCarpiUlnaris, with: self.muscleUsage(for: .ExtensorCarpiUlnaris))
                        .setGradient(geometry.size)
                }
                
                ZStack {
                    PosteriorShape(.ExtensorPollicisBrevis, with: self.muscleUsage(for: .ExtensorPollicisBrevis))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.EntensorPollicisLongus, with: self.muscleUsage(for: .EntensorPollicisLongus))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.GastrocnemiusMedialHead, with: self.muscleUsage(for: .GastrocnemiusMedialHead))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.GastrocnemiusLateralHead, with: self.muscleUsage(for: .GastrocnemiusLateralHead))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.IliotibialBand, with: self.muscleUsage(for: .IliotibialBand))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.ErectorSpinae, with: self.muscleUsage(for: .ErectorSpinae))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.Abductor, with: self.muscleUsage(for: .Abductor))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.LateralDeltoid, with: self.muscleUsage(for: .LateralDeltoid))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.PosteriorDeltoid, with: self.muscleUsage(for: .PosteriorDeltoid))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.Body)
                        .stroke(Color(#colorLiteral(red: 0.9134874683, green: 0.9134874683, blue: 0.9134874683, alpha: 1)), lineWidth: 0.7)
                }
            }
        }
            .padding()
    }
}

struct PosteriorView_Previews: PreviewProvider {
    static var previews: some View {
        PosteriorView(
            activatedTargetMuscles: [],
            activatedSynergistMuscles: []
        )
    }
}
