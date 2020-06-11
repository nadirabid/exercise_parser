//
//  MapView.swift
//  client
//
//  Created by Nadir Muzaffar on 6/16/19.
//  Copyright © 2019 Nadir Muzaffar. All rights reserved.
//

import Foundation
import CoreLocation
import Combine
import MapKit
import SwiftUI

// MARK: run tracker view

struct RunTrackerMapView: UIViewRepresentable {
    var trackUserPath: Bool
    @ObservedObject var locationManager: RunTrackerLocationManager
    
    func makeUIView(context: Context) -> MKMapView {
        let view = MKMapView()
        view.userTrackingMode = .follow
        
        self.locationManager.startUpdatingLocation()
        
        return view
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        view.delegate = context.coordinator

        if let currentLocation = locationManager.lastLocation?.coordinate {
            let span = MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
            let region = MKCoordinateRegion(center: currentLocation, span: span)
            view.setRegion(region, animated: true)
        }

        if !view.overlays.isEmpty {
            view.removeOverlays(view.overlays)
        }
        
        if self.trackUserPath {
            let l = MKPolyline(coordinates: locationManager.pathCoordinates, count: locationManager.pathCoordinates.count)
            view.addOverlay(l)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: RunTrackerMapView
        
        init(_ parent: RunTrackerMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = secondaryAppColor.uiColor()
            renderer.lineWidth = 7
            return renderer
        }
    }
}

class RunTrackerLocationManager: NSObject, ObservableObject {
    @Published var pathCoordinates: [CLLocationCoordinate2D] = []
    let objectWillChange = PassthroughSubject<Void, Never>()
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.activityType = .fitness
        self.locationManager.showsBackgroundLocationIndicator = true
        self.locationManager.distanceFilter = 5
        self.locationManager.requestAlwaysAuthorization()
    }
    
    func startUpdatingLocation() {
        self.locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        self.locationManager.stopUpdatingLocation()
    }

    @Published var locationStatus: CLAuthorizationStatus? {
        willSet {
            objectWillChange.send()
        }
    }

    @Published var lastLocation: CLLocation? {
        willSet {
            objectWillChange.send()
        }
    }

    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }

        switch status {
        case .notDetermined: return "Can't say"
        case .authorizedWhenInUse: return "While Using"
        case .authorizedAlways: return "Always"
        case .restricted: return "Restricted"
        case .denied: return "Nope"
        default: return "Weird"
        }
    }
}

extension RunTrackerLocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationStatus = status
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastLocation = location
        self.pathCoordinates.append(location.coordinate)
    }
}

// MARK: workout map view

struct WorkoutMapView: UIViewRepresentable {
    var location: Location
    
    func makeUIView(context: Context) -> MKMapView {
        let view = MKMapView(frame: .zero)
        
        let coordinate = CLLocationCoordinate2D(
            latitude: self.location.latitude,
            longitude: self.location.longitude
        )
        let span = MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        view.setRegion(region, animated: true)
        view.isZoomEnabled = false
        view.isScrollEnabled = false
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        view.addAnnotation(annotation)
        
        return view
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        
    }
}

class LocationManager: NSObject, ObservableObject {
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }

    @Published var locationStatus: CLAuthorizationStatus? {
        willSet {
            objectWillChange.send()
        }
    }

    @Published var lastLocation: CLLocation? {
        willSet {
            objectWillChange.send()
        }
    }

    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }

        switch status {
        case .notDetermined: return "Can't say"
        case .authorizedWhenInUse: return "While Using"
        case .authorizedAlways: return "Always"
        case .restricted: return "Restricted"
        case .denied: return "Nope"
        default: return "Weird"
        }
    }

    let objectWillChange = PassthroughSubject<Void, Never>()

    private let locationManager = CLLocationManager()
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationStatus = status
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastLocation = location
    }
}

#if DEBUG
struct MapView_Previews : PreviewProvider {
    static var previews: some View {
        WorkoutMapView(location: Location(latitude: 37.34711392, longitude: -121.88290191))
    }
}
#endif
