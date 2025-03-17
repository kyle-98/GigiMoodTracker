//
//  ContentView.swift
//  GigiMoodTracker
//
//  Created by Kyle on 3/16/25.
//

import SwiftUI

struct ContentView: View {
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
        }
    }
}

#Preview {
    ContentView()
}
