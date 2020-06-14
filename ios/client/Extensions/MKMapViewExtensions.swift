//
//  MKMapView.swift
//  client
//
//  Created by Nadir Muzaffar on 6/13/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    func setRegionFrom(path: [Location], animated: Bool = false) {
        let filtered = path.filter { $0.latitude != 0 && $0.longitude != 0 }
        
        if filtered.isEmpty {
            return
        } else if filtered.count == 1 {
            let span = MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
            let center = CLLocationCoordinate2D(latitude: filtered.first!.latitude, longitude: filtered.first!.longitude)
            let region = MKCoordinateRegion(center: center, span: span)
            self.setRegion(region, animated: animated)
        }
        
        let padding = 0.0025
        let minLatitude = filtered.min(by: { $0.latitude < $1.latitude }).map { $0.latitude }! - padding
        let maxLatitude = filtered.max(by: { $0.latitude < $1.latitude }).map { $0.latitude }! + padding
        let minLongitude = filtered.min(by: { $0.longitude < $1.longitude }).map { $0.longitude }! - padding
        let maxLongitude = filtered.max(by: { $0.longitude < $1.longitude }).map { $0.longitude }! + padding
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLatitude - minLatitude),
            longitudeDelta: (maxLongitude - minLongitude)
        )
        
        let center = CLLocationCoordinate2D(
            latitude: minLatitude + span.latitudeDelta / 2,
            longitude: minLongitude + span.longitudeDelta / 2
        )
        
        let region = MKCoordinateRegion(center: center, span: span)
        
        self.setRegion(region, animated: animated)
    }
}
