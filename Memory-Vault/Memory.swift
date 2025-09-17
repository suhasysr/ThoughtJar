//
//  Thought.swift
//  Memory Vault
//
//  Created by Suhas Vasu on 9/15/25.
//


import Foundation
import SwiftUI

// A simple data model for a memory.
struct Memory: Identifiable, Equatable { // Equatable is added for easier comparison
    let id: UUID
    var text: String
    var date: String
    
    init(id: UUID = UUID(), text: String, date: String) {
        self.id = id
        self.text = text
        self.date = date
    }
}

// ObservableObject to manage the list of memories.
class MemoryData: ObservableObject {
    @Published var memories: [Memory] = [
        Memory(text: "The best view comes after the hardest climb.", date: "June 15, 2024"),
        Memory(text: "Don't count the days, make the days count.", date: "June 14, 2024"),
        Memory(text: "Success is not final, failure is not fatal: it is the courage to continue that counts.", date: "June 13, 2024"),
        Memory(text: "The only way to do great work is to love what you do.", date: "June 12, 2024"),
        Memory(text: "An unexamined life is not worth living.", date: "June 11, 2024")
    ]
    
    // Method to add a new memory to the list.
    func addMemory(text: String) {
        let newMemory = Memory(text: text, date: DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))
        memories.insert(newMemory, at: 0) // Adds the new memory to the beginning of the array.
    }
    
    // Method to delete a memory.
    func deleteMemory(memoryId: UUID) {
        memories.removeAll { $0.id == memoryId }
    }
    
    // Method to update an existing memory.
    func updateMemory(memory: Memory) {
        if let index = memories.firstIndex(where: { $0.id == memory.id }) {
            memories[index] = memory
        }
    }
}
