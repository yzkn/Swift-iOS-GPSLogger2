//
//  TrackingView.swift
//  GPSLogger2
//
//  Created by Yu on 2024/07/04.
//

import SwiftData
import SwiftUI
import CoreLocation

struct TrackingView: View {
    @StateObject var locationViewModel = LocationViewModel()
    @Query private var items: [Item]

    var body: some View {
        Text(
            String(coordinate?.latitude ?? 0) +
            "," +
            String(coordinate?.longitude ?? 0)
        )
            .font(.footnote)
    }

    var coordinate: CLLocationCoordinate2D? {
        locationViewModel.lastSeenLocation?.coordinate
    }
}

struct TrackingView_Previews: PreviewProvider {
    static var previews: some View {
        TrackingView()
            .modelContainer(for: Item.self)
    }
}
