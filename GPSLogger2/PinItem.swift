//
//  PinItem.swift
//  GPSLogger2
//
//  Created by Yu on 2024/07/11.
//

import Foundation
import CoreLocation

struct PinItem: Identifiable {
    let id = UUID()
    let latitude: Double
    let longitude: Double
    var coodinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
}
