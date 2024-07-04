//
//  Item.swift
//  GPSLogger2
//
//  Created by Yu on 2024/07/04.
//

import Foundation
import SwiftData

@Model
class Item {
    // https://developer.apple.com/documentation/corelocation/cllocation
    var id: UUID
    
    var title: String
    var notes: String
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var hAccuracy: Double
    var vAccuracy: Double
    var course: Double
    var speed: Double
    var timestamp: Date
    var address: String

    init(
        title: String,
        notes: String,
        latitude: Double,
        longitude: Double,
        altitude: Double,
        hAccuracy: Double,
        vAccuracy: Double,
        course: Double,
        speed: Double,
        timestamp: Date,
        address: String
    ) {
        self.id = UUID()
        
        self.title = title
        self.notes = notes
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.hAccuracy = hAccuracy
        self.vAccuracy = vAccuracy
        self.course = course
        self.speed = speed
        self.timestamp = timestamp
        self.address = address
    }
}
