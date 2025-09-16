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
            // Pass the generated random thought directly to TodayView.
            TodayView(todaysMemory: todaysMemory)
                .tabItem {
                    Label("Today", systemImage: "calendar")
                }
            
            // Pass the shared thoughtData object to NewThoughtView.
            NewMemoryView(memoryData: memoryData)
                .tabItem {
                    Label("New Memory", systemImage: "pencil.and.scribble")
                }
        }
        .onAppear {
            // This code runs only once when the app is launched.
            // Check if a random thought has already been selected.
            if self.todaysMemory == nil {
                // Select and store a random thought from the data source.
                self.todaysMemory = memoryData.memories.randomElement()
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
