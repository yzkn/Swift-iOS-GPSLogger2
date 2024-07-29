//
//  LongTaskManager.swift
//  GPSLogger2
//
//  Created by Yu on 2024/07/29.
//

import UIKit


final class LongTaskManager {
  static let shared = LongTaskManager()
  private var timer: Timer?
  private var backgroundTaskID: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)
  private var oldBackgroundTaskID: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)
  
  func start(interval: Double = 10) {
      timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { _ in
          self.oldBackgroundTaskID = self.backgroundTaskID

          self.backgroundTaskID = UIApplication.shared.beginBackgroundTask { [weak self] in
              guard let backgroundTaskID = self?.backgroundTaskID else { return }
              UIApplication.shared.endBackgroundTask(backgroundTaskID)
              self?.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
          }
          UIApplication.shared.endBackgroundTask(self.oldBackgroundTaskID)
      })
  }

  func end() {
      timer?.invalidate()
      timer = nil
      UIApplication.shared.endBackgroundTask(backgroundTaskID)
      UIApplication.shared.endBackgroundTask(oldBackgroundTaskID)
  }
}
