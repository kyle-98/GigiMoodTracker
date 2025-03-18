//
//  ContentView.swift
//  GigiMoodTracker
//
//  Created by Kyle on 3/16/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var refreshFlag = false

    var body: some View {
        NavigationStack {
                VStack(spacing: 0) {
                    HStack {
                        // Settings Icon - Align it vertically with the month switcher in CalendarView
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape")
                                .font(.title3)
                                .padding(.leading, 20) // Optional padding for positioning
                                .padding(.top, 10) // Adjust this to bring the gear icon down
                        }
                        Spacer() // Push the icon to the left
                    }

                    // Add the CalendarView
                    CalendarView()
                        .padding(.top, -40) // Adjust this to bring the calendar view up closer to the icon
                        .onChange(of: scenePhase) { _, newPhase in
                            if newPhase == .active {
                                refreshCalendar()
                            }
                        }
                }
                .padding(.top, -10) // Ensure the top area has enough padding
            }
        
        
        
//        NavigationStack {
//            CalendarView()
//                .toolbar {
//                    ToolbarItem(placement: .topBarLeading) {
//                        NavigationLink(destination: SettingsView()) {
//                            Image(systemName: "gearshape")
//                                .font(.title3)
//                        }
//                        
//                    }
//                    
//                }
//                .onChange(of: scenePhase) { _, newPhase in
//                    if newPhase == .active {
//                        refreshCalendar()
//                    }
//                }
//        }
        
        
    }

    // Function to trigger the refresh
    private func refreshCalendar() {
        refreshFlag.toggle()
    }
}

#Preview {
    ContentView()
}
