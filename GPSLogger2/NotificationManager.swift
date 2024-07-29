//
//  NotificationManager.swift
//  GPSLogger2
//
//  Created by Yu on 2024/07/26.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let instance: NotificationManager = NotificationManager()

    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { (granted, _) in
                // print("Permission granted: \(granted)")
            }
    }
    
    func sendNotification(count:Int, message:String) {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {setting in
            if setting.authorizationStatus == .authorized {
                let content = UNMutableNotificationContent()
                content.badge = NSNumber.init(value: count)
                content.title = "GPSLogger2"
                content.subtitle = "Location updated."
                content.sound = UNNotificationSound.default
                content.body = message
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest(identifier: "GPSLogger2", content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
        })
    }
}
