//
//  PersistenceController.swift
//  Memory-Vault
//
//  Created by Suhas Vasu on 10/26/25.
//


import CoreData

struct PersistenceController {
    // A shared singleton for the whole app
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // Use the model file we just created
        container = NSPersistentContainer(name: "MemoryModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        // Helps merge duplicate objects
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}