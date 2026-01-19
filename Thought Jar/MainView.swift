//
//  MainView.swift
//  Memory Vault
//
//  Created by Suhas Vasu on 9/8/25.
//


import SwiftUI
import CoreData

struct MainView: View {
    // Get the database context from the environment
    @Environment(\.managedObjectContext) private var viewContext
    
    // This will hold the Core Data Memory object
    @State private var todaysMemory: Memory?
    
    // UserDefaults keys
    private let lastPickDateKey = "lastPickDate"
    private let todaysMemoryIDKey = "todaysMemoryID"
    
    init() {
        // --- Tab Bar Color Fix ---
        let activeColor = UIColor(hex: 0x4A6D63)
        let inactiveColor = UIColor(hex: 0x4A6D63, alpha: 0.5)
        UITabBar.appearance().tintColor = activeColor
        UITabBar.appearance().unselectedItemTintColor = inactiveColor
        
        // --- TextEditor Fix ---
        UITextView.appearance().backgroundColor = .clear
        
        // --- NEW FIXES FOR DARK MODE ---
        
        // 1. Fix Navigation Title Color ("Notifications")
        // This sets the title color to our app's darkColor
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor(hex: 0x2C3E50) // Your darkColor
        ]
        
        // 2. Fix Segmented Picker Text Color ("Daily", "Weekly")
        // This sets the color for the unselected segments
        UISegmentedControl.appearance().setTitleTextAttributes([
            .foregroundColor: UIColor(hex: 0x2C3E50) // Your darkColor
        ], for: .normal)
        
        // This sets the text color for the selected segment to white for better contrast
        UISegmentedControl.appearance().setTitleTextAttributes([
            .foregroundColor: UIColor.white
        ], for: .selected)
        
        // --- FIX FOR SEGMENTED CONTROL HIGHLIGHT COLOR ---
        // This sets the background color of the selected segment
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(hex: 0x4A6D63) // Your primaryColor
        
        // --- END OF NEW FIXES ---
    }
    
    var body: some View {
        TabView {
            TodayView(todaysMemory: todaysMemory)
                .tabItem {
                    Label("Today", systemImage: "calendar")
                }
            
            // Pass the binding for todaysMemory
            NewMemoryView(todaysMemory: $todaysMemory)
                .tabItem {
                    Label("New Thought", systemImage: "pencil.and.scribble")
                }
        }
        // We no longer need .accentColor() here, as .appearance() handles it
        .onAppear {
            // Run the logic to set up the daily memory
            setupTodaysMemory()
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
        if let idString = defaults.string(forKey: todaysMemoryIDKey), let memoryID = UUID(uuidString: idString) {
            
            // 'memoryID' is correctly used here, INSIDE the 'if' block
            if let savedMemory = fetchMemory(withId: memoryID) {
                todaysMemory = savedMemory
            } else {
                // The saved memory was deleted from Core Data. Pick a new one.
                pickAndSaveNewRandomMemory()
            }
        } else {
            // Couldn't find a saved ID. Pick a new one.
            pickAndSaveNewRandomMemory()
        }
    }

    private func pickAndSaveNewRandomMemory() {
        // Fetch all memories from Core Data
        let allMemories = fetchAllMemories()
        
        if let newMemory = allMemories.randomElement() {
            todaysMemory = newMemory
            
            // Save this new memory to UserDefaults
            let defaults = UserDefaults.standard
            defaults.set(Date(), forKey: lastPickDateKey) // Save today's date
            defaults.set(newMemory.id?.uuidString, forKey: todaysMemoryIDKey) // Save the ID
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
    
    // --- Core Data Fetch Functions ---
    
    private func fetchAllMemories() -> [Memory] {
        let request: NSFetchRequest<Memory> = Memory.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Memory.date, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch memories: \(error)")
            return []
        }
    }
    
    private func fetchMemory(withId id: UUID) -> Memory? {
        let request: NSFetchRequest<Memory> = Memory.fetchRequest()
        // Use a predicate to find the exact memory
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            return try viewContext.fetch(request).first
        } catch {
            print("Failed to fetch single memory: \(error)")
            return nil
        }
    }
}
