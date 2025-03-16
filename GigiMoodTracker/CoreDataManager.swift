import CoreData
import SwiftUI

class CoreDataManager {
    
    // Create a persistent container
    private let container: NSPersistentContainer
    static let shared = CoreDataManager()

    init() {
        container = NSPersistentContainer(name: "Moods")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    
    // Fetch Mood selections for a specific month based on the `date` attribute
    func fetchSelections(forMonth month: String) -> [Mood] {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<Mood> = Mood.fetchRequest()
        
        // Fetch moods where the `date` starts with the given month (e.g., "2025-03")
        let predicate = NSPredicate(format: "date BEGINSWITH %@", month)
        fetchRequest.predicate = predicate
        
        do {
            let selections = try context.fetch(fetchRequest)
            return selections
        } catch {
            print("Failed to fetch Mood selections: \(error)")
            return []
        }
    }

    // Save a Mood selection (add or update) for a specific date
    func saveMoodSelection(date: String, moodImage: String) {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<Mood> = Mood.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date == %@", date)
        
        do {
            let existingMood = try context.fetch(fetchRequest).first
            if let mood = existingMood {
                mood.moodValue = moodImage // Update the existing record
            } else {
                let newMood = Mood(context: context)
                newMood.date = date
                newMood.moodValue = moodImage
            }
            try context.save()  // Save the context
            print("successfully saved mood selection for \(date) and \(moodImage)")
        } catch {
            print("Failed to save Mood selection: \(error)")
        }
    }

    
    // New function to update or create a Mood selection for a specific date
    func updateMoodSelection(dateString: String, moodValue: String) {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<Mood> = Mood.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date == %@", dateString)
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if let existingMood = results.first {
                // If a Mood entry exists, update it
                existingMood.moodValue = moodValue
            } else {
                // If no entry exists, create a new Mood
                let newMood = Mood(context: context)
                newMood.date = dateString
                newMood.moodValue = moodValue
            }
            
            // Save the changes
            try context.save()
            print("saving for mood: \(moodValue) and date: \(dateString)")
        } catch {
            print("Failed to update or create Mood selection: \(error)")
        }
    }
    
    // Fetch all Mood entities (optional, you can tailor this as needed)
    func fetchAllMoods() -> [Mood] {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<Mood> = Mood.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch all Moods: \(error)")
            return []
        }
    }
}
