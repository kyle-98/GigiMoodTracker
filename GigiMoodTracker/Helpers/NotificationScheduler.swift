//
//  NotificationScheduler.swift
//  GigiMoodTracker
//
//  Created by Kyle on 3/17/25.
//

import UserNotifications
import Foundation
import CoreData

// Function to check if the user has already selected a mood for today
func checkMoodForToday() -> Bool {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let currentDateString = dateFormatter.string(from: Date())

    let fetchRequest: NSFetchRequest<Mood> = Mood.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "date == %@", currentDateString)

    do {
        let results = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
        print("Fetched moods: \(results)")
        return results.isEmpty  // Return true if no mood is found for today
    } catch {
        print("Error fetching mood for today: \(error.localizedDescription)")
        return true  // Assume mood needs to be set if there was an error
    }
}

// Function to schedule the notification
func scheduleDailyNotification(at time: Date) {
    let center = UNUserNotificationCenter.current()

    // Remove existing notifications before scheduling a new one
    center.removeAllPendingNotificationRequests()
    
    // Check if a mood is already set for today
    if checkMoodForToday() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)

        // Set the notification trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        // Create the notification content
        let content = UNMutableNotificationContent()
        content.title = "GigiMoodTracker"
        content.body = "gimurin would be very disappointed if you didn't track your mood for the day"
        content.sound = .default

        // Create the notification request
        let request = UNNotificationRequest(identifier: "dailyMoodReminder", content: content, trigger: trigger)
        print("Notification request: \(request)")

        // Schedule the notification
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled successfully.")
            }
        }
    } else {
        print("Mood already set for today. No notification scheduled.")
    }
}
