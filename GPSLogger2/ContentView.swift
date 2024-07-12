//
//  ContentView.swift
//  GPSLogger2
//
//  Created by Yu on 2024/07/04.
//

import SwiftData
import SwiftUI
import CoreLocation
import MapKit

struct ContentView: View {
    @State private var isShowConfirmDelete = false
    @State private var isShowAlertAllItemDeleted = false
    @State private var isShowAlertAllItemExported = false
    
    @State private var triggerAdd: Bool?
    @State private var triggerExport: Bool?
    @State private var triggerKml: Bool?
    @State private var triggerRemove: Bool?
    
    @State private var globeBlue = true
    @State private var searchTerm: String = ""
    
    @StateObject var locationViewModel = LocationViewModel()
    
    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]
    private var filteredItems: [Item] {
        guard !searchTerm.isEmpty else { return items }
        return items.filter { $0.address.contains(searchTerm) || String($0.latitude).contains(searchTerm) || String($0.longitude).contains(searchTerm)}
    }
    
    private var coordinate: CLLocationCoordinate2D? {
        locationViewModel.lastSeenLocation?.coordinate
    }
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    GeometryReader { g in

                        VStack {
                            ZStack {
                                HStack{
                                    Map(
                                         interactionModes: .all
                                    )
                                    {
                                        UserAnnotation()
                                        
                                        ForEach(filteredItems, id: \.self) { item in
                                            Marker(coordinate: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)) {
                                                Text(item.address)
                                                Image(systemName: "mappin")
                                            }
                                            .tint(.blue)
                                        }
                                    }
                                    .mapControls {
                                        MapCompass()
                                            .mapControlVisibility(.visible)
                                        MapScaleView()
                                            .mapControlVisibility(.visible)
                                        MapUserLocationButton()
                                            .mapControlVisibility(.visible)
                                    }
                                }
                            }.frame(width: g.size.width, height: g.size.height/2, alignment: .center)

                            ZStack {
                                HStack{
                                    List(filteredItems) { item in
                                        VStack(alignment: .leading) {
                                            Text(item.address)
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
                                }
                            }.frame(width: g.size.width, height: g.size.height/2, alignment: .center)
                        }
                    }
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)

            }
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Text("GPSLogger2")
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    TextField("検索", text: $searchTerm)
                        .frame(width: 60.0)
                        .padding()
                        .cornerRadius(5)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        if triggerExport == nil {
                            triggerExport = true
                        } else {
                            triggerExport?.toggle()
                        }
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .task(id: triggerExport) {
                        guard triggerExport != nil else { return }
                        
                        let csv = await ItemService.shared.getCsv()
                        
                        let fileManager = FileManager.default
                        let docPath =  NSHomeDirectory() + "/Documents"
                        
                        let df = DateFormatter()
                        df.dateFormat = "yyyyMMddHHmmss"
                        let ds = df.string(from: Date())
                    
                        let fileName = ds + ".csv"
                        let filePath = docPath + "/" + fileName
                        
                        if !fileManager.fileExists(atPath: filePath) {
                            // fileManager.createFile(atPath:filePath, contents: csv.data(using: .utf8), attributes: [:])
                            if let strm = OutputStream(toFileAtPath: filePath, append: false){
                                strm.open()
                                let BOM = "\u{feff}"
                                strm.write(BOM, maxLength: 3)
                                let data = csv.data(using: .utf8)
                                _ = data?.withUnsafeBytes {
                                    strm.write($0.baseAddress!, maxLength: Int(data?.count ?? 0))
                                }
                                strm.close()
                            }
                            isShowAlertAllItemExported.toggle()
                        }
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        if triggerKml == nil {
                            triggerKml = true
                        } else {
                            triggerKml?.toggle()
                        }
                    }) {
                        Image(systemName: "square.and.arrow.up.fill")
                    }
                    .task(id: triggerKml) {
                        guard triggerKml != nil else { return }
                        
                        let kml = await ItemService.shared.getKml()
                        
                        let fileManager = FileManager.default
                        let docPath =  NSHomeDirectory() + "/Documents"
                        
                        let df = DateFormatter()
                        df.dateFormat = "yyyyMMddHHmmss"
                        let ds = df.string(from: Date())
                    
                        let fileName = ds + ".kml"
                        let filePath = docPath + "/" + fileName
                        
                        if !fileManager.fileExists(atPath: filePath) {
                            if let strm = OutputStream(toFileAtPath: filePath, append: false){
                                strm.open()
                                let BOM = "\u{feff}"
                                strm.write(BOM, maxLength: 3)
                                let data = kml.data(using: .utf8)
                                _ = data?.withUnsafeBytes {
                                    strm.write($0.baseAddress!, maxLength: Int(data?.count ?? 0))
                                }
                                strm.close()
                            }
                            isShowAlertAllItemExported.toggle()
                        }
                    }
                }
                
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        if globeBlue {
                            globeBlue = false
                            locationViewModel.stopUpdate()
                        } else {
                            globeBlue = true
                            locationViewModel.startUpdate()
                            
                            locationViewModel.lastSeenLocation = nil
                            locationViewModel.forceUpdate()
                        }
                    }) {
                        switch locationViewModel.authorizationStatus {
                        case .authorizedAlways, .authorizedWhenInUse:
                            if globeBlue {
                                Image(systemName: "globe.desk")
                                    .foregroundStyle(.blue)
                            } else {
                                Image(systemName: "globe.desk.fill")
                                    .foregroundStyle(.gray)
                            }
                        default:
                            Image(systemName: "globe.desk.fill")
                                .foregroundStyle(.gray)
                        }
                    }
                    .id(globeBlue)
                    
                    Spacer()
                    
                    switch locationViewModel.authorizationStatus {
                    case .notDetermined:
                        Button(action: {
                            locationViewModel.requestPermission()
                        }) {
                            Text("位置情報の使用を許可する")
                        }
                    case .restricted:
                        ErrorView(errorText: "位置情報の使用が制限されています。")
                    case .denied:
                        ErrorView(errorText: "位置情報を使用できません。")
                    case .authorizedAlways, .authorizedWhenInUse:
                        if(coordinate == nil){
                            Text("---")
                        } else {
                            Text(
                                String(coordinate?.latitude ?? 0) +
                                "," +
                                String(coordinate?.longitude ?? 0)
                            ).font(.footnote)
                        }
                    default:
                        Text("Unexpected status")
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        isShowConfirmDelete.toggle()
                    }) {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .alert("Are you sure you want to delete all items?", isPresented: $isShowConfirmDelete) {
            Button("Cancel") {
            }
            Button("OK") {
                if triggerRemove == nil {
                    triggerRemove = true
                } else {
                    triggerRemove?.toggle()
                }
            }
            .task(id: triggerRemove) {
                guard triggerRemove != nil else { return }
                let result = await ItemService.shared.deleteAllItems()
                locationViewModel.lastSeenLocation = nil
                if(result){
                    isShowAlertAllItemDeleted.toggle()
                }
            }
        }
        .alert("All items were removed.", isPresented: $isShowAlertAllItemDeleted) {
        }
        .alert("All items were exported.", isPresented: $isShowAlertAllItemExported) {
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self)
}
