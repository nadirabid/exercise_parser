//
//  ActivityView.swift
//  client
//
//  Created by Nadir Muzaffar on 2/26/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct ActivityView : View {
    var workout: Activity
    var asSecondary: Bool = false
    
    var body: some View {
        HStack {
            Text(workout.name)
                .font(.subheadline)
                .foregroundColor(asSecondary ? .secondary : .primary)
            
            Spacer()
            
            HStack {
                ForEach(workout.units, id: \.self) { unit in
                    VStack(alignment: .trailing, spacing: 1.0) {
                        Text(unit[0])
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(unit[1])
                            .font(.headline)
                            .foregroundColor(self.asSecondary ? .secondary : .primary)
                    }
                    .padding(.leading, 2.0)
                }
            }
        }
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        let workouts: [Activity] = [
            Activity(name: "Running", units: [["mi", "0.7"]]),
            Activity(name: "Rowing", units: [["m", "700"], ["mins", "4"]]),
        ]
        
        return Group {
            ActivityView(workout: workouts[0])
            ActivityView(workout: workouts[1])
        }
        .previewLayout(.fixed(width: 400, height: 70))
    }
}
