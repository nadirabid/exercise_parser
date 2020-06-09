//
//  RunTrackerView.swift
//  client
//
//  Created by Nadir Muzaffar on 6/7/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI
import MapKit

struct RunTrackerView: View {
    var body: some View {
        VStack {
            RunTrackerMapView(trackUserPath: false)
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct RunTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        RunTrackerView()
    }
}
