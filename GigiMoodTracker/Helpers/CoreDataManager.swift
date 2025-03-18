import CoreData
import SwiftUI

class CoreDataManager {
    
    // Create a persistent container, this is where all the key/value pair data will be stored
    private let container: NSPersistentContainer
    static let shared = CoreDataManager()

    //Initalize the container
    init() {
        container = NSPersistentContainer(name: "GigiMoodStorage")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    
    // Fetch mood selections for a specific month based on the date attribute
    func fetchSelections(forMonth month: String) -> [Mood] {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<Mood> = Mood.fetchRequest()
        
        // Fetch moods where the date attribute starts with the given month (e.g. 2025-03)
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
    
    // Function to update or create a mood selection for a specific date
    func updateMoodSelection(dateString: String, moodValue: String) {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<Mood> = Mood.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date == %@", dateString)
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if let existingMood = results.first {
                // If a mood entry exists, update it
                existingMood.moodValue = moodValue
            } else {
                // If no entry exists, create a new mood entry with the currently selected date and image key/value pair
                let newMood = Mood(context: context)
                newMood.date = dateString
                newMood.moodValue = moodValue
            }
            
            // Save the changes in core data
            try context.save()
        } catch {
            print("Failed to update or create Mood selection: \(error)")
        }
    }
    
    // Fetch all mood entries from core data
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
    
    func deleteMoodSelection(dateString: String) {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<Mood> = Mood.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date == %@", dateString)

        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                context.delete(object) // Remove the Core Data entry
            }
            try context.save() // Save changes
        } catch {
            print("Failed to delete mood selection: \(error)")
        }
    }
}
