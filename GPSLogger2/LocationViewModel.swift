//
//  LocationViewModel.swift
//  GPSLogger2
//
//  Created by Yu on 2024/07/04.
//

import CoreLocation

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var lastSeenLocation: CLLocation?

    private let locationManager: CLLocationManager
    
    override init() {
        locationManager = CLLocationManager()
        authorizationStatus = locationManager.authorizationStatus
        
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1
        locationManager.allowsBackgroundLocationUpdates = true // バックグラウンド実行
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
    }

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization() // バックグラウンド実行
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastSeenLocation = locations.first
        
        guard let location = lastSeenLocation else {
            return
        }

        // print("緯度: ",location.coordinate.latitude, "経度: ", location.coordinate.longitude)
        
        Task{
            await addItem(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                altitude: location.altitude,
                hAccuracy: location.horizontalAccuracy,
                vAccuracy: location.verticalAccuracy,
                course: location.course,
                speed: location.speed,
                timestamp: location.timestamp
            )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\(error)")
    }
    
    func forceUpdate() {
        locationManager.requestLocation()
    }
    
    private func addItem(
        latitude: Double,
        longitude: Double,
        altitude: Double,
        hAccuracy: Double,
        vAccuracy: Double,
        course: Double,
        speed: Double,
        timestamp: Date
    ) async {
        let added = await ItemService.shared.createItem(
            title: "",
            notes: "",
            latitude: latitude,
            longitude: longitude,
            altitude: altitude,
            hAccuracy: hAccuracy,
            vAccuracy: vAccuracy,
            course: course,
            speed: speed,
            timestamp: timestamp,
            address: ""
        )
    }
}
