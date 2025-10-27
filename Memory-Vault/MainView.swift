//
//  MainView.swift
//  Memory Vault
//
//  Created by Suhas Vasu on 9/8/25.
//


import SwiftUI

struct MainView: View {
    @StateObject private var memoryData = MemoryData()
    
    // State variable to hold the random thought to be displayed.
    @State private var todaysMemory: Memory?
    
    // Define keys for UserDefaults
        private let lastPickDateKey = "lastPickDate"
        private let todaysMemoryIDKey = "todaysMemoryID"
    
    var body: some View {
        TabView {
            TodayView(todaysMemory: todaysMemory)
                .tabItem {
                    Label("Today", systemImage: "calendar")
                }
            
            // Pass the binding for todaysMemory
            NewMemoryView(memoryData: memoryData, todaysMemory: $todaysMemory)
                .tabItem {
                    Label("New Memory", systemImage: "pencil.and.scribble")
                }
        }
        .onAppear {
            // Run the logic to set up the daily memory
            setupTodaysMemory()
        }
        .onChange(of: memoryData.memories) { oldMemories, newMemories in
            // This logic handles deletions or the very first memory being added.
            
            // If all memories are deleted, clear today's memory
            if newMemories.isEmpty {
                todaysMemory = nil
                clearTodaysMemoryFromDefaults() // Clear from storage too
            }
            // If today's memory was just deleted, pick a new one for today
            else if let currentMemory = todaysMemory, !newMemories.contains(where: { $0.id == currentMemory.id }) {
                pickAndSaveNewRandomMemory()
            }
            // If this is the *first* memory being added, set it as today's memory
            else if oldMemories.isEmpty && !newMemories.isEmpty {
                pickAndSaveNewRandomMemory()
            }
        }
    }

    // --- Helper Functions for Daily Memory ---

    private func setupTodaysMemory() {
        let defaults = UserDefaults.standard
        let savedDate = defaults.object(forKey: lastPickDateKey) as? Date
        
        // Check 1: Is there a saved date and is it today?
        if let date = savedDate, Calendar.current.isDateInToday(date) {
            // It's the same day. Load the saved memory.
            loadSavedMemory()
        } else {
            // It's a new day or the first launch. Pick a new memory.
            pickAndSaveNewRandomMemory()
        }
    }

    private func loadSavedMemory() {
        let defaults = UserDefaults.standard
        
        // Get the saved ID string from UserDefaults
        if let idString = defaults.string(forKey: todaysMemoryIDKey), let id = UUID(uuidString: idString) {
            
            // Find the memory in our data model
            if let savedMemory = memoryData.memories.first(where: { $0.id == id }) {
                // Found it! Set it as today's memory.
                todaysMemory = savedMemory
            } else {
                // The saved memory was deleted. Pick a new one.
                pickAndSaveNewRandomMemory()
            }
        } else {
            // Couldn't find a saved ID. Pick a new one.
            pickAndSaveNewRandomMemory()
        }
    }

    private func pickAndSaveNewRandomMemory() {
        // Make sure we actually have memories to pick from
        if let newMemory = memoryData.memories.randomElement() {
            // Set the state
            todaysMemory = newMemory
            
            // Save this new memory to UserDefaults
            let defaults = UserDefaults.standard
            defaults.set(Date(), forKey: lastPickDateKey) // Save today's date
            defaults.set(newMemory.id.uuidString, forKey: todaysMemoryIDKey) // Save the ID
        } else {
            // No memories exist, set to nil
            todaysMemory = nil
            clearTodaysMemoryFromDefaults()
        }
    }
    
    private func clearTodaysMemoryFromDefaults() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: lastPickDateKey)
        defaults.removeObject(forKey: todaysMemoryIDKey)
    }
}

// Preview provider for Xcode's Canvas.
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
