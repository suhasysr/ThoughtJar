//
//  Memory_VaultApp.swift
//  Memory-Vault
//
//  Created by Suhas Vasu on 9/15/25.
//

import SwiftUI

@main
struct ThoughtJarApp: App {
    // Create the persistence controller
    let persistenceController = PersistenceController.shared
    
    // This init() runs before any view is created
    init() {
        // This makes all TextEditor backgrounds transparent by default
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
            // Inject the managed object context into the environment
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
