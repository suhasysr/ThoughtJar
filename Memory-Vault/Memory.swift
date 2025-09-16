//
//  Thought.swift
//  Memory Vault
//
//  Created by Suhas Vasu on 9/15/25.
//


import Foundation
import SwiftUI

// A simple data model for a thought.
// Identifiable is crucial for ForEach loops in SwiftUI.
struct Memory: Identifiable {
    let id = UUID()
    var text: String
    var date: String
}

// ObservableObject to manage the list of thoughts.
// Any view observing this object will automatically update when its data changes.
class MemoryData: ObservableObject {
    @Published var memories: [Memory] = [
        Memory(text: "The best view comes after the hardest climb.", date: "June 15, 2024"),
        Memory(text: "Don't count the days, make the days count.", date: "June 14, 2024"),
        Memory(text: "Success is not final, failure is not fatal: it is the courage to continue that counts.", date: "June 13, 2024"),
        Memory(text: "The only way to do great work is to love what you do.", date: "June 12, 2024"),
        Memory(text: "An unexamined life is not worth living.", date: "June 11, 2024")
    ]
    
    // Method to add a new thought to the list.
    func addThought(text: String) {
        let newMemory = Memory(text: text, date: DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))
        memories.insert(newMemory, at: 0) // Adds the new thought to the beginning of the array.
    }
}
