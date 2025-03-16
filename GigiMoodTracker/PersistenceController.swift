import CoreData

class PersistenceController {
    static let shared = PersistenceController()

    // The container is where your Core Data stack resides
    let container: NSPersistentContainer

    init() {
        // The name here should be the name of the .xcdatamodeld file
        container = NSPersistentContainer(name: "GigiMoodTracker") // Match with .xcdatamodeld name (without extension)
        
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
}
