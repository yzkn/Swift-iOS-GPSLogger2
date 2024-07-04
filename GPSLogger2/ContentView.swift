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
    @State private var triggerAdd: Bool?
    @State private var triggerRemove: Bool?
    @StateObject var locationViewModel = LocationViewModel()
    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]
    
    var body: some View {
        NavigationView {
            List(items) { item in
                VStack(alignment: .leading) {
                    Text(item.title)
                    HStack{
                        Text(String(item.latitude))
                        Text(",")
                        Text(String(item.longitude))
                    }
                    HStack{
                        Text(item.timestamp, style: .date)
                            .foregroundColor(.secondary)
                        Text(item.timestamp, style: .time)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    switch locationViewModel.authorizationStatus {
                    case .authorizedAlways, .authorizedWhenInUse:
                        Image(systemName: "globe")
                            .foregroundStyle(.tint)
                    default:
                        Image(systemName: "globe")
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Text("GPSLogger2")
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                
                ToolbarItemGroup(placement: .bottomBar) {
                    VStack() {
                    Button(action: {
                        if triggerAdd == nil {
                            triggerAdd = true
                        } else {
                            triggerAdd?.toggle()
                        }
                    }) {
                        Image(systemName: "mappin")
                    }
                    }
                    .task(id: triggerAdd) {
                        guard triggerAdd != nil else { return }
                        do {
                            locationViewModel.forceUpdate()
                            // try await ItemService.shared.createItemLastSeen()
                        } catch {
                        }
                    }
                    
                    VStack() {
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
                    }
                    VStack() {
                        Button(action: {
                            if triggerRemove == nil {
                                triggerRemove = true
                            } else {
                                triggerRemove?.toggle()
                            }
                        }) {
                            Image(systemName: "trash")
                        }
                    }
                    .task(id: triggerRemove) {
                        guard triggerRemove != nil else { return }
                        do {
                            try await ItemService.shared.deleteAllItems()
                        } catch {
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self)
}
