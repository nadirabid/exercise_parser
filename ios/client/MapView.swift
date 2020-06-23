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

struct StaticTrackerMapView: UIViewRepresentable {
    var path: [Location] = []
    var userTrackingMode: MKUserTrackingMode
    
    func makeUIView(context: Context) -> MKMapView {
        let view = MKMapView()
        view.userTrackingMode = userTrackingMode
        view.isZoomEnabled = false
        view.isScrollEnabled = false
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = context.coordinator
        
        let sorted = path.sorted { $0.index! < $1.index! }
        
        var pathsCoords: [[CLLocationCoordinate2D]] = [[]]
        
        for location in sorted {
            let zero = CLLocationCoordinate2D.zero
            let coord = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            if zero == coord {
                pathsCoords.append([])
            } else {
                pathsCoords[pathsCoords.count - 1].append(coord)
            }
        }
        
        for p in pathsCoords {
            let l = MKPolyline(coordinates: p, count: p.count)
            view.addOverlay(l)
        }
        
        view.setRegionFrom(path: path)
        
        return view
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        view.delegate = context.coordinator
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: StaticTrackerMapView
        
        init(_ parent: StaticTrackerMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = secondaryAppColor.uiColor()
            renderer.lineWidth = 4
            return renderer
        }
    }
}

struct RunTrackerMapView: UIViewRepresentable {
    @ObservedObject var locationManager: RunTrackerLocationManager
    var userTrackingMode: MKUserTrackingMode
    
    func makeUIView(context: Context) -> MKMapView {
        let view = MKMapView()
        view.userTrackingMode = userTrackingMode
        
        return view
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        view.userTrackingMode = userTrackingMode
        view.delegate = context.coordinator
        
        if let currentLocation = locationManager.lastLocation?.coordinate {
            let span = MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
            let region = MKCoordinateRegion(center: currentLocation, span: span)
            view.setRegion(region, animated: locationManager.pathCoordinates.count == 1)
        }
        
        if !view.overlays.isEmpty {
            view.removeOverlays(view.overlays)
        }
        
        var paths: [[CLLocationCoordinate2D]] = [[]]
        
        for c in locationManager.pathCoordinates {
            let zero = CLLocationCoordinate2D.zero
            if c.longitude == zero.longitude && c.latitude == zero.longitude {
                paths.append([])
            } else {
                paths[paths.count - 1].append(c)
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
        print("locationManager:start")
        self.locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        print("locationManager:stop")
        self.locationManager.stopUpdatingLocation()
    }
    
    func startTrackingLocation() {
        self.trackPath = true
    }
    
    func stopTrackingLocation() {
        // we add a zero coord to mark stop/start
        if pathCoordinates.count > 0 {
            let last = self.pathCoordinates.last!
            
            if last != CLLocationCoordinate2D.zero {
                self.pathCoordinates.append(CLLocationCoordinate2D.zero)
                
                if let handler = self.locationUpdateHandler {
                    handler(self.pathCoordinates.count, CLLocationCoordinate2D.zero)
                }
            }
        }
        
        self.trackPath = false // do this AFTER calling updateHnadler
    }
    
    var isTrackingPath: Bool {
        return self.trackPath
    }
    
    var currentDistance: CLLocationDistance {
        var distance = CLLocationDistance.zero
        var last: CLLocation? = nil
        let zero = CLLocationCoordinate2D.zero
        
        for c in self.pathCoordinates {
            let l = CLLocation(latitude: c.latitude, longitude: c.longitude)
            
            if last != nil && c != zero && last!.coordinate != zero {
                let d = last!.distance(from: l)
                distance = distance + d
            }
            
            last = l
        }
        
        return distance
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
