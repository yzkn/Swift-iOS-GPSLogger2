//
//  GPSLogger2App.swift
//  GPSLogger2
//
//  Created by Yu on 2024/07/04.
//

import SwiftUI

@main
struct GPSLogger2App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(Persistance.sharedModelContainer)
        }
    }
}
