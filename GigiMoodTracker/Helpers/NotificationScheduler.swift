//
//  NotificationScheduler.swift
//  GigiMoodTracker
//
//  Created by Kyle on 3/17/25.
//

import UserNotifications
import Foundation

func scheduleDailyNotification(at time: Date) {
    let center = UNUserNotificationCenter.current()

    // Remove existing notifications before scheduling a new one
    center.removeAllPendingNotificationRequests()
    
    // Get the current time and minute
    let calendar = Calendar.current
    let components = calendar.dateComponents([.hour, .minute], from: time)
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

    // Create the notification content
    let content = UNMutableNotificationContent()
    content.title = "GigiMoodTracker"
    content.body = "gimurin would be very disappointed if you didn't track your mood for the day"
    content.sound = .default
    
    let request = UNNotificationRequest(identifier: "dailyMoodReminder", content: content, trigger: trigger)

    center.add(request) { error in
        if let error = error {
            print("Error scheduling notification: \(error)")
        }
    }
}
