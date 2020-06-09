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
    @State var directions: [CLLocation] = [CLLocation(latitude: 27.2041206, longitude: 84.6093928), CLLocation(latitude: 20.7712763, longitude: 73.7317739)]
    var body: some View {
        VStack {
            RunTrackerMapView(trackUserPath: true)
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct RunTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        RunTrackerView()
    }
}
