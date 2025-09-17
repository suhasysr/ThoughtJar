//
//  MainView.swift
//  Memory Vault
//
//  Created by Suhas Vasu on 9/8/25.
//


import SwiftUI

struct MainView: View {
    // Create a single instance of your data model to be shared.
    @StateObject private var memoryData = MemoryData()
    
    // State variable to hold the random thought to be displayed.
    @State private var todaysMemory: Memory?
    
    var body: some View {
        TabView {
            // Pass the generated random memory directly to TodayView.
            TodayView(todaysMemory: todaysMemory)
                .tabItem {
                    Label("Today", systemImage: "calendar")
                }
            
            // Pass the shared memoryData object AND a binding for todaysMemory to NewThoughtView.
            NewMemoryView(memoryData: memoryData, todaysMemory: $todaysMemory)
                .tabItem {
                    Label("New Memory", systemImage: "pencil.and.scribble")
                }
        }
        .onAppear {
            // This code runs only once when the app is launched.
            // Check if a random memory has already been selected or if there are any memories.
            if self.todaysMemory == nil && !memoryData.memories.isEmpty {
                self.todaysMemory = memoryData.memories.randomElement()
            }
        }
        // Observe changes in memoryData.memories to potentially update todaysMemory
        .onChange(of: memoryData.memories) { oldMemories, newMemories in
            // If todaysMemory was deleted and there are still memories left, pick a new one
            if todaysMemory != nil && !newMemories.contains(where: { $0.id == todaysMemory!.id }) {
                todaysMemory = newMemories.randomElement()
            } else if todaysMemory == nil && !newMemories.isEmpty {
                 // If there was no todaysMemory previously and now there are memories, pick one
                todaysMemory = newMemories.randomElement()
            } else if newMemories.isEmpty {
                // If all memories are deleted, ensure todaysMemory is nil
                todaysMemory = nil
            }
        }
    }
}

// Preview provider for Xcode's Canvas.
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
