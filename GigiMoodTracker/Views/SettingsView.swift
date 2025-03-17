//
//  SettingsView.swift
//  GigiMoodTracker
//
//  Created by Kyle on 3/17/25.
//


import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationTime") private var notificationTime = Date()

    var body: some View {
        VStack {
            // Header text
            Text("Settings")
                .font(.largeTitle)
                .bold()
                .padding()
            // Form the allow for storing settings functionalities
            Form {
                Section(header: Text("Notifications")) {
                    DatePicker("Reminder Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                        .onChange(of: notificationTime, initial: true) { oldValue, newValue in
                            scheduleDailyNotification(at: newValue)
                        }
                }
            }
            .padding()

            Spacer()
        }
    }
}

// Enable the preview of in the debug viewer
#Preview {
    SettingsView()
}
