//
//  AppDelegate.swift
//  GPSLogger2
//
//  Created by Yu on 2024/07/04.
//

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        NotificationManager.instance.requestPermission()
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([[.banner, .sound, .badge]])
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        LongTaskManager.shared.start()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        LongTaskManager.shared.end()
    }
}
