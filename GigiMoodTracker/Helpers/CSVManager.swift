//
//  CSVManager.swift
//  GigiMoodTracker
//
//  Created by Kyle on 3/17/25.
//

import Foundation
import CoreData
import UIKit

// Class for handling CSV generation, export, and import
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
    
    // Import data from CSV
    static func importData(from url: URL) {
        print("Importing data...")
        DispatchQueue.global(qos: .background).async {
            do {
                // Read the CSV data
                let data = try Data(contentsOf: url)
                
                // Convert to a string
                if let csvString = String(data: data, encoding: .utf8) {
                    let rows = csvString.split(separator: "\n")
                    
                    // Clear existing Core Data
                    clearExistingMoods()
                    print("cleared moods")
                    
                    // Start inserting new data
                    for row in rows.dropFirst() { // Skip header row
                        let columns = row.split(separator: ",")
                        if columns.count == 2 {
                            CoreDataManager.shared.updateMoodSelection(dateString: String(columns[0]), moodValue: String(columns[1]))
                        }
                    }
                    
                    DispatchQueue.main.async {
                        print("CSV import complete")
                    }
                }
            } catch {
                print("Error importing CSV: \(error)")
            }
        }
    }
    
    // Clear existing moods from Core Data
    private static func clearExistingMoods() {
        let fetchRequest: NSFetchRequest<Mood> = Mood.fetchRequest()
        let context = PersistenceController.shared.viewContext
        do {
            let moods = try context.fetch(fetchRequest)
            for mood in moods {
                context.delete(mood)
            }
            try context.save()
        } catch {
            print("Error clearing existing moods: \(error)")
        }
    }
}
