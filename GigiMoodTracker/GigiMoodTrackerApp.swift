//
//  GigiMoodTrackerApp.swift
//  GigiMoodTracker
//
//  Created by Kyle on 3/16/25.
//

import SwiftUI
import UserNotifications

@main
struct GigiMoodTrackerApp: App {
    // Request notifications permissions on initial app launch
    init() {
        requestNotificationPermissions()
    }
    
    // Show the full content of the app
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Function to request notification permissions from user on initial app launch. This will ask for all notification permissions of alert, sound, and badge
func requestNotificationPermissions() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if let error = error {
            print("Notification permission error: \(error)")
        } else if granted {
            print("Notifications allowed")
        } else {
            print("Notifications denied")
        }
    }
}
