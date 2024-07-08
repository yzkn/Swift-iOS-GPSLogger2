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
    @State private var isShowConfirmDelete = false
    @State private var isShowAlertAllItemDeleted = false
    @State private var isShowAlertAllItemExported = false
    
    @State private var triggerAdd: Bool?
    @State private var triggerExport: Bool?
    @State private var triggerRemove: Bool?
    
    @State private var globeBlue = true
    
    @StateObject var locationViewModel = LocationViewModel()
    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]
    
    var coordinate: CLLocationCoordinate2D? {
        locationViewModel.lastSeenLocation?.coordinate
    }
    
    var body: some View {
        NavigationView {
            List(items) { item in
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
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        if globeBlue {
                            globeBlue = false
                            locationViewModel.stopUpdate()
                        } else {
                            globeBlue = true
                            locationViewModel.startUpdate()
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
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Text("GPSLogger2")
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
                            locationViewModel.forceUpdate()
                    }
                    
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
                        Text(
                            String(coordinate?.latitude ?? 0) +
                            "," +
                            String(coordinate?.longitude ?? 0)
                        )
                            .font(.footnote)
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
