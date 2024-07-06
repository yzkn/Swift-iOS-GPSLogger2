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
                        print(csv)
                        
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
                            
                            //
                            
                            let viewController = UIActivityViewController(activityItems: [csv], applicationActivities: nil)
                            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                            let window = windowScene?.windows.first
                            window?.rootViewController?.present(viewController, animated: true)
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                viewController.popoverPresentationController?.sourceView = window
                                viewController.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2.1 , y: UIScreen.main.bounds.height / 1.3, width: 200, height: 200)
                            }
                            
                            //
                            
                            print("File created.")
                            // isShowAlertAllItemExported.toggle()
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
