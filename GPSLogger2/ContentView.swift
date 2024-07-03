//
//  ContentView.swift
//  GPSLogger2
//
//  Created by Yu on 2024/07/04.
//

import SwiftData
import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject var locationViewModel = LocationViewModel()
    @Query private var items: [Item]
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("GPSLogger2")
            
            switch locationViewModel.authorizationStatus {
            case .notDetermined:
                RequestLocationView()
                    .environmentObject(locationViewModel)
            case .restricted:
                ErrorView(errorText: "位置情報の使用が制限されています。")
            case .denied:
                ErrorView(errorText: "位置情報を使用できません。")
            case .authorizedAlways, .authorizedWhenInUse:
                TrackingView()
                    .environmentObject(locationViewModel)
            default:
                Text("Unexpected status")
            }
            
            List(items) { item in
                VStack(alignment: .leading) {
                    Text(item.title)
                    Text(item.timestamp, style: .date)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self)
}
