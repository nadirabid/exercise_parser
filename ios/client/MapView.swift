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

func centerMapOnLocation(_ location: CLLocation, mapView: MKMapView) {
    let regionRadius: CLLocationDistance = 1000
    let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                              latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
    mapView.setRegion(coordinateRegion, animated: true)
}

struct RunTrackerMapView: UIViewRepresentable {
    @ObservedObject var locationManager: RunTrackerLocationManager
    
    func makeUIView(context: Context) -> MKMapView {
        let view = MKMapView()
        view.userTrackingMode = .follow
        
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
        
        var paths: [[CLLocationCoordinate2D]] = [[]]
        var currentPath: [CLLocationCoordinate2D] = paths.last!
        
        for c in locationManager.pathCoordinates {
            let zero = CLLocationCoordinate2D.zero
            if c.longitude == zero.longitude && c.latitude == zero.longitude {
                currentPath = []
                paths.append(currentPath)
            } else {
                currentPath.append(c)
            }
        }
        
        for p in paths {
            let l = MKPolyline(coordinates: p, count: p.count)
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

typealias LocationUpdateHandler = ((Int, CLLocationCoordinate2D) -> Void)

class RunTrackerLocationManager: NSObject, ObservableObject {
    @Published var pathCoordinates: [CLLocationCoordinate2D] = []
    var locationUpdateHandler: LocationUpdateHandler?
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    private var trackPath = false
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.activityType = .fitness
        self.locationManager.showsBackgroundLocationIndicator = true
        self.locationManager.distanceFilter = 6
        self.locationManager.requestAlwaysAuthorization()
        
        self.locationUpdateHandler = nil
    }
    
    func startUpdatingLocation() {
        self.locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        self.locationManager.stopUpdatingLocation()
    }
    
    func startTrackingLocation() {
        self.trackPath = true
    }
    
    func stopTrackingLocation() {
        self.trackPath = false
        
        // we add a zero coord to mark stop/start
        if pathCoordinates.count > 0 {
            let last = self.pathCoordinates.last!
            
             if last.latitude != CLLocationCoordinate2D.zero.latitude &&
                last.longitude != CLLocationCoordinate2D.zero.longitude {
                self.pathCoordinates.append(CLLocationCoordinate2D.zero)
            }
        }
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
    
    var isLocationEnabled: Bool {
        guard let status = locationStatus else {
            return false
        }
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        case .notDetermined, .restricted, .denied:
            return false
        default:
            return false
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
        
        if self.trackPath {
            self.pathCoordinates.append(location.coordinate)
        }
        
        if let handler = self.locationUpdateHandler {
            handler(self.pathCoordinates.count, location.coordinate)
        }
    }
}

extension CLLocationCoordinate2D {
    static var zero: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: CLLocationDegrees.zero,
            longitude: CLLocationDegrees.zero
        )
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
