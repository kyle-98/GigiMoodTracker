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
                .padding(.top)

            // Form for storing settings
            Form {
                Section(header: Text("Notifications").font(.headline)) {
                    DatePicker("Daily Reminder Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                        .onChange(of: notificationTime, initial: true) { oldValue, newValue in
                            scheduleDailyNotification(at: newValue)
                        }
                        .padding()
                        
                }
                
                Section {
                    Button(action: {
                        CSVManager.exportData()
                    }) {
                        Text("Export Data")
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.1)))
                            
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .listStyle(GroupedListStyle())
            .background(Color(UIColor.systemGroupedBackground))
            .cornerRadius(20)
            .padding()

            Spacer()
        }
        .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
    }
}

// Enable the preview of in the debug viewer
#Preview {
    SettingsView()
}

