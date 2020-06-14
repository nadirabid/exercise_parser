//
//  CLLocationCoordinate2D.swift
//  client
//
//  Created by Nadir Muzaffar on 6/13/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D {
    static var zero: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: CLLocationDegrees.zero,
            longitude: CLLocationDegrees.zero
        )
    }
    
    static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    static func != (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return !(lhs == rhs)
    }
}
