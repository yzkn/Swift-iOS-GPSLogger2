//
//  LocationViewModel.swift
//  GPSLogger2
//
//  Created by Yu on 2024/07/04.
//

import CoreLocation
// import MapKit

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var lastSeenLocation: CLLocation?
    // @Published var lastSeenRegion: MKCoordinateRegion?
    
    @Published var isLocatingRunning: Bool = true

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
        
         if lastSeenLocation != nil && locations.last != nil {
             if lastSeenLocation!.distance(from: locations.last!) < 1 {
                 return
             }
         }
        
         // print("running: ", isLocatingRunning)
         if isLocatingRunning {
             //
         } else {
             return
         }
        
        lastSeenLocation = locations.last
        guard let location = lastSeenLocation else {
            return
        }
        
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
            let revGeo = ReverseGeocoding()
            let label = revGeo.townDatastore.search(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
            
            let createdItem = await ItemService.shared.createItem(
                title: "",
                notes: "",
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                altitude: location.altitude,
                hAccuracy: location.horizontalAccuracy,
                vAccuracy: location.verticalAccuracy,
                course: location.course,
                speed: location.speed,
                timestamp: location.timestamp,
                address: label ?? ""
            )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\(error)")
    }
    
    func startUpdate() {
        isLocatingRunning = true
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdate() {
        isLocatingRunning = false
        locationManager.stopUpdatingLocation()
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
}
