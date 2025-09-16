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
    
    var body: some View {
        TabView {
            // Pass the thoughtData object to TodayView.
            TodayView(memoryData: memoryData)
                .tabItem {
                    Label("Today", systemImage: "calendar")
                }
            
            // Pass the same thoughtData object to NewThoughtView.
            NewMemoryView(memoryData: memoryData)
                .tabItem {
                    Label("New Memory", systemImage: "pencil.and.scribble")
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
