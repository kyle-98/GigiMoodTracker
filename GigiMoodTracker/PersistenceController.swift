import CoreData

class PersistenceController {
    static let shared = PersistenceController()

    // This will store the active container used to store all the mood selections for each day
    let container: NSPersistentContainer

    // Get the container
    init() {
        container = NSPersistentContainer(name: "GigiMoodTracker")
        
        // Load the values stored in the core data container
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    // Return the values obtains from the container
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
}
