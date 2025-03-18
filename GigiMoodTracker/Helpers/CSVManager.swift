//
//  CSVManager.swift
//  GigiMoodTracker
//
//  Created by Kyle on 3/17/25.
//

import Foundation
import CoreData
import UIKit

// Class for handling CSV generation and export
class CSVManager {

    // Fetch all moods from core data
    static func fetchAllMoods() -> [Mood] {
        let fetchRequest: NSFetchRequest<Mood> = Mood.fetchRequest()
        let context = PersistenceController.shared.viewContext
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch moods: \(error)")
            return []
        }
    }

    // Generate CSV string from fetched moods
    static func generateCSV() -> String {
        var csvString = "Date,MoodImage\n" // Add the header row

        let moods = fetchAllMoods()
        for mood in moods {
            if let date = mood.date, let moodImage = mood.moodValue {
                csvString.append("\(date),\(moodImage)\n")
            }
        }

        return csvString
    }

    // Export data as CSV
    static func exportData() {
        let csvString = generateCSV()

        // Convert the CSV string to Data
        if let data = csvString.data(using: .utf8) {
            // Create a temporary file URL
            let fileName = "MoodData.csv"
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

            do {
                // Write the CSV data to the temporary file
                try data.write(to: tempURL)
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    if let rootVC = windowScene.windows.first?.rootViewController {
                        let activityController = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
                        
                        // Show the share sheet
                        rootVC.present(activityController, animated: true, completion: nil)
                    }
                }
            } catch {
                print("Error writing CSV file: \(error)")
            }
        }
    }
}

