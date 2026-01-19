//
//  MemoryRandomizer.swift
//  Thought Jar
//
//  Created by Suhas Vasu on 1/19/26.
//

import Foundation
import CoreData

struct MemoryRandomizer {
    
    /// Picks a random memory from the provided list, optimizing to avoid
    /// picking the same memory that was just displayed (consecutive repeats).
    ///
    /// - Parameter memories: The list of Memory objects to choose from.
    /// - Returns: A randomly selected Memory, or nil if the list is empty.
    static func pick(from memories: [Memory]) -> Memory? {
        // 1. Basic checks
        guard !memories.isEmpty else { return nil }
        if memories.count == 1 { return memories.first }
        
        // 2. Retrieve the ID of the memory currently/last displayed
        let defaults = UserDefaults.standard
        let lastPickedIDString = defaults.string(forKey: "todaysMemoryID")
        
        // 3. Filter candidates: Exclude the one with the matching ID
        let candidates = memories.filter { memory in
            guard let id = memory.id?.uuidString else { return true }
            return id != lastPickedIDString
        }
        
        // 4. Select from candidates.
        // If candidates is empty (e.g., only 2 memories existed and we filtered the last one out? 
        // actually if count > 1, candidates shouldn't be empty unless all IDs match which is impossible),
        // fallback to the full list.
        let pool = candidates.isEmpty ? memories : candidates
        
        return pool.randomElement()
    }
}
