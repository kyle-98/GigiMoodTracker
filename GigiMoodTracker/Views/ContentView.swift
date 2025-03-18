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
            CalendarView()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape")
                                .font(.title2)
                        }
                    }
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        refreshCalendar()
                    }
                }
        }
    }

    // Function to trigger the refresh
    private func refreshCalendar() {
        refreshFlag.toggle()
    }
}
