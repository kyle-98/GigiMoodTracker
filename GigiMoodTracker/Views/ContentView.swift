//
//  ContentView.swift
//  GigiMoodTracker
//
//  Created by Kyle on 3/16/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        // Main view
        NavigationStack {
            // Populate the calendar for the current month
            CalendarView()
                // Add a settings button in the top left
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape")
                                .font(.title2)
                        }
                    }
                }
        }
    }
}

// Show the app in the debug preview
#Preview {
    ContentView()
}
