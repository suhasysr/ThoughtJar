//
//  Memory_VaultApp.swift
//  Memory-Vault
//
//  Created by Suhas Vasu on 9/15/25.
//

import SwiftUI

@main
struct MemoryVaultApp: App {
    // Create the persistence controller
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            MainView()
            // Inject the managed object context into the environment
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
