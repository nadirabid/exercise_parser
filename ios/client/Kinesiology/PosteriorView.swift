//
//  PosteriorView.swift
//  client
//
//  Created by Nadir Muzaffar on 5/1/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct FocusedPosteriorShape: Shape {
    let muscle: Muscle
    let usage: MuscleUsage
    let activiation: Double
    let path: Path
    let scaleToSize: CGRect
    let center: CGPoint
    
    static let absoluteSize: CGSize = CGSize(width: 658.16, height: 1125.9)
    
    init(_ muscle: Muscle, relativeSize: CGRect, center: CGPoint, _ activation: Double = 0, with usage: MuscleUsage = .none) {
        self.muscle = muscle
        self.scaleToSize = relativeSize
        self.usage = usage
        self.activiation = activation
        self.path = PosteriorPath.from(muscle: muscle)
        self.center = center
    }
    
    func path(in rect: CGRect) -> Path {
        let scaleX = rect.size.width / scaleToSize.width
        let scaleY = rect.size.height / scaleToSize.height
        
        let factor = min(scaleX, max(scaleY, 0.0))
        let center = self.center
        
        var transform  = CGAffineTransform.identity
        
        transform = transform.concatenating(CGAffineTransform(translationX: -center.x, y: -center.y))
        transform = transform.concatenating(CGAffineTransform(scaleX: factor, y: factor))
        transform = transform.concatenating(CGAffineTransform(translationX: rect.midX, y: rect.midY))
        
        return path.applying(transform)
    }
    
    func setGradient(_ size: CGSize) -> some View {
        var radial: RadialGradient
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        
        let scaleX = rect.size.width / scaleToSize.width
        let scaleY = rect.size.height / scaleToSize.height
        
        let factor = min(scaleX, max(scaleY, 0.0))
        let center = self.center
        
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
            let opacity = self.activiation * 0.6
            let colors = Gradient(colors: [secondaryAppColor.opacity(opacity), Color.yellow.opacity(opacity), appColor.opacity(opacity)])
            radial = RadialGradient(
                gradient: colors,
                center: radialCenter,
                startRadius: startRadius,
                endRadius: endRadius
            )
        case .dynamicArticulation:
            let opacity = self.activiation * 0.5
            let colors = Gradient(colors: [Color.green.opacity(opacity), Color.blue.opacity(opacity), Color(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)).opacity(opacity)])
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
}

struct FocusedPosteriorView: View {
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
    
    var muscleActivations: [MuscleActivation] {
        return (activatedTargetMuscles + activatedSynergistMuscles + activatedDynamicArticulationMuscles).filter { $0.muscle.orientation == .Posterior }
    }
    
    var rect: (CGRect, CGPoint) {
        let rect = PosteriorPath.boundingBoxForMuscles(muscles: muscleActivations.map { $0.muscle })
        
        return rect
    }
    
    var body: some View {
        ZStack {
            FocusedPosteriorShape(.Background, relativeSize: rect.0, center: rect.1).fill(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
            
            ForEach(muscleActivations, id: \.muscle) { (activation: MuscleActivation) in
                FocusedPosteriorShape(activation.muscle, relativeSize: self.rect.0, center: self.rect.1, activation.activation, with: self.muscleUsage(for: activation.muscle))
                    .setGradient(self.rect.0.size)
            }
            
            FocusedPosteriorShape(.Body, relativeSize: rect.0, center: rect.1).stroke(Color(#colorLiteral(red: 0.9134874683, green: 0.9134874683, blue: 0.9134874683, alpha: 1)), lineWidth: 0.7)
        }
    }
}

struct PosteriorShape: Shape {
    let muscle: Muscle
    let usage: MuscleUsage
    let activiation: Double
    let path: Path
    
    static let absoluteSize: CGSize = CGSize(width: 480.75, height: 845.55)
    
    init(_ muscle: Muscle, _ activation: Double = 0, with usage: MuscleUsage = .none) {
        self.muscle = muscle
        self.usage = usage
        self.activiation = activation
        self.path = PosteriorPath.from(muscle: muscle)
    }
    
    func path(in rect: CGRect) -> Path {
        let scaleX = rect.size.width / PosteriorShape.absoluteSize.width
        let scaleY = rect.size.height / PosteriorShape.absoluteSize.height
        
        let factor = min(scaleX, max(scaleY, 0.0))
        let center = CGPoint(x: PosteriorShape.absoluteSize.width / 2, y: PosteriorShape.absoluteSize.height / 2)
        
        var transform  = CGAffineTransform.identity
        
        transform = transform.concatenating(CGAffineTransform(translationX: -center.x, y: -center.y))
        transform = transform.concatenating(CGAffineTransform(scaleX: factor, y: factor))
        transform = transform.concatenating(CGAffineTransform(translationX: rect.midX, y: rect.midY))
        
        return path.applying(transform)
    }
    
    func setGradient(_ size: CGSize) -> some View {
        var radial: RadialGradient
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        
        let scaleX = rect.size.width / PosteriorShape.absoluteSize.width
        let scaleY = rect.size.height / PosteriorShape.absoluteSize.height
        
        let factor = min(scaleX, max(scaleY, 0.0))
        let center = CGPoint(x: PosteriorShape.absoluteSize.width / 2, y: PosteriorShape.absoluteSize.height / 2)
        
        var transform  = CGAffineTransform.identity
        
        transform = transform.concatenating(CGAffineTransform(translationX: -center.x, y: -center.y))
        transform = transform.concatenating(CGAffineTransform(scaleX: factor, y: factor))
        transform = transform.concatenating(CGAffineTransform(translationX: rect.midX, y: rect.midY))
        
        let bounds = self.path.boundingRect.applying(transform)
        let radialCenter = UnitPoint(x: bounds.midX / size.width, y: bounds.midY / size.height)
        let startRadius = 0.3 * max(bounds.width, bounds.height)
        let endRadius = max(bounds.width, bounds.height)
        
        print("here", self.muscle, self.usage, self.activiation)
        
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
            let opacity = self.activiation * 0.6
            let colors = Gradient(colors: [secondaryAppColor.opacity(opacity), Color.yellow.opacity(opacity), appColor.opacity(opacity)])
            radial = RadialGradient(
                gradient: colors,
                center: radialCenter,
                startRadius: startRadius,
                endRadius: endRadius
            )
        case .dynamicArticulation:
            let opacity = self.activiation * 0.5
            let colors = Gradient(colors: [Color.green.opacity(opacity), Color.blue.opacity(opacity), Color(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)).opacity(opacity)])
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
        
        let scaleX = rect.size.width / PosteriorShape.absoluteSize.width
        let scaleY = rect.size.height / PosteriorShape.absoluteSize.height
        
        let factor = min(scaleX, max(scaleY, 0.0))
        
        return CGSize(width: PosteriorShape.absoluteSize.width*factor, height: PosteriorShape.absoluteSize.height*factor)
    }
}

struct PosteriorView: View {
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
        return GeometryReader { geometry in
            ZStack {
                ZStack {
                    PosteriorShape(.Background)
                        .fill(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                    
                    PosteriorShape(.ExternalOblique, self.muscleActivation(for: .ExternalOblique), with: self.muscleUsage(for: .ExternalOblique))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.LatissimusDorsi, self.muscleActivation(for: .LatissimusDorsi), with: self.muscleUsage(for: .LatissimusDorsi))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.RhomboidMajor, self.muscleActivation(for: .RhomboidMajor), with: self.muscleUsage(for: .RhomboidMajor))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.GluteusMaximus, self.muscleActivation(for: .GluteusMaximus), with: self.muscleUsage(for: .GluteusMaximus))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.GluteusMedius, self.muscleActivation(for: .GluteusMedius), with: self.muscleUsage(for: .GluteusMedius))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.BicepsFemoris, self.muscleActivation(for: .BicepsFemoris), with: self.muscleUsage(for: .BicepsFemoris))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.Semitendinosus, self.muscleActivation(for: .Semitendinosus), with: self.muscleUsage(for: .Semitendinosus))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.Infraspinatus, self.muscleActivation(for: .Infraspinatus), with: self.muscleUsage(for: .Infraspinatus))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.TeresMajor, self.muscleActivation(for: .TeresMajor), with: self.muscleUsage(for: .TeresMajor))
                        .setGradient(geometry.size)
                }
                
                ZStack {
                    PosteriorShape(.TrapeziusLowerFibers, self.muscleActivation(for: .TrapeziusLowerFibers), with: self.muscleUsage(for: .TrapeziusLowerFibers))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.TrapeziusMiddleFibers, self.muscleActivation(for: .TrapeziusMiddleFibers), with: self.muscleUsage(for: .TrapeziusMiddleFibers))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.TrapeziusUpperFibers, self.muscleActivation(for: .TrapeziusUpperFibers), with: self.muscleUsage(for: .TrapeziusUpperFibers))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.TricepsLongHead, self.muscleActivation(for: .TricepsLongHead), with: self.muscleUsage(for: .TricepsLongHead))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.TricepsLateralHead, self.muscleActivation(for: .TricepsLateralHead), with: self.muscleUsage(for: .TricepsLateralHead))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.Anconeus, self.muscleActivation(for: .Anconeus), with: self.muscleUsage(for: .Anconeus))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.FlexorCarpiUlnaris, self.muscleActivation(for: .FlexorCarpiUlnaris), with: self.muscleUsage(for: .FlexorCarpiUlnaris))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.Brachioradialis, self.muscleActivation(for: .Brachioradialis), with: self.muscleUsage(for: .Brachioradialis))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.ExtensorDigitorum, self.muscleActivation(for: .ExtensorDigitorum), with: self.muscleUsage(for: .ExtensorDigitorum))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.ExtensorCarpiUlnaris, self.muscleActivation(for: .ExtensorCarpiUlnaris), with: self.muscleUsage(for: .ExtensorCarpiUlnaris))
                        .setGradient(geometry.size)
                }
                
                ZStack {
                    PosteriorShape(.ExtensorPollicisBrevis, self.muscleActivation(for: .ExtensorPollicisBrevis), with: self.muscleUsage(for: .ExtensorPollicisBrevis))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.EntensorPollicisLongus, self.muscleActivation(for: .EntensorPollicisLongus), with: self.muscleUsage(for: .EntensorPollicisLongus))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.GastrocnemiusMedialHead, self.muscleActivation(for: .GastrocnemiusMedialHead), with: self.muscleUsage(for: .GastrocnemiusMedialHead))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.GastrocnemiusLateralHead, self.muscleActivation(for: .GastrocnemiusLateralHead), with: self.muscleUsage(for: .GastrocnemiusLateralHead))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.IliotibialBand, self.muscleActivation(for: .IliotibialBand), with: self.muscleUsage(for: .IliotibialBand))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.ErectorSpinae, self.muscleActivation(for: .ErectorSpinae), with: self.muscleUsage(for: .ErectorSpinae))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.Abductor, self.muscleActivation(for: .Abductor), with: self.muscleUsage(for: .Abductor))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.LateralDeltoid, self.muscleActivation(for: .LateralDeltoid), with: self.muscleUsage(for: .LateralDeltoid))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.PosteriorDeltoid, self.muscleActivation(for: .PosteriorDeltoid), with: self.muscleUsage(for: .PosteriorDeltoid))
                        .setGradient(geometry.size)
                    
                    PosteriorShape(.Body)
                        .stroke(Color(#colorLiteral(red: 0.9134874683, green: 0.9134874683, blue: 0.9134874683, alpha: 1)), lineWidth: 0.7)
                }
            }
        }
    }
}

struct PosteriorView_Previews: PreviewProvider {
    static var previews: some View {
        PosteriorView(
            activatedTargetMuscles: [],
            activatedSynergistMuscles: [],
            activatedDynamicArticulationMuscles: []
        )
    }
}
