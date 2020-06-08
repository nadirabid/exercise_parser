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
    private var locationManager = LocationManager()
    
    var location: Location? {
        let coord: CLLocationCoordinate2D? = locationManager.lastLocation?.coordinate
        return coord != nil ? Location(latitude: coord!.latitude, longitude: coord!.longitude) : nil
    }
    
    var body: some View {
        
        return VStack {
            if self.location != nil {
                MapView(location: self.location!)
                    .frame(height: 130)
            }
        }
    }
}

struct RunTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        RunTrackerView()
    }
}
