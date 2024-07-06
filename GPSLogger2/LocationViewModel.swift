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
        
        let lat = getPreferenceDoubleValue(key: "home_area_latitude")
        let lon = getPreferenceDoubleValue(key: "home_area_longitude")
        let rad = getPreferenceDoubleValue(key: "home_area_radius")
        
        if(lat == 0 || lon == 0 || rad == 0){
            // 未設定なので記録
        } else {
            // 設定済
            let home = CLLocation(latitude: lat ?? 0, longitude: lon ?? 0)
            if(location.distance(from: home) < rad ?? 0){
                // Home area内なのでスキップ
                return
            } else {
                // Home areaの外なので記録
            }
        }
        
        // print(String(lat ?? 0), String(lon ?? 0), String(rad ?? 0))
        
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
    
    func getPreferenceDoubleValue(key: String) -> Double? {
        return UserDefaults.standard.double(forKey: key)
    }
    
    func getPreferenceStringValue(key: String) -> String?{
        return UserDefaults.standard.string(forKey: key)
    }
    
    func setPreferenceValue(key: String, val:Any) {
        UserDefaults.standard.set(val, forKey: key)
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
        let _ = await ItemService.shared.createItem(
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
