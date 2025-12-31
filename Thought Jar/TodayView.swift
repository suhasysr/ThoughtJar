//
//  TodayView.swift
//  Memory Vault
//
//  Created by Suhas Vasu on 9/7/25.
//


import SwiftUI

struct TodayView: View {
    let todaysMemory: Memory? // Make it @ObservedObject
    
    // --- NEW ---
    // State to control the notification settings modal
    @State private var showNotificationSheet = false

    // Color Definitions
    static let mutedBackground = Color(hex: 0xE5E7E4)
    // New Primary/Accent Color
    static let primaryColor = Color(hex: 0x4A6D63)
    // New Dark Text/Header Color
    static let darkColor = Color(hex: 0x2C3E50)
    
    var body: some View {
        // Use a ZStack to layer the content over the background color.
        ZStack {
            // Use the soft, creamy background
            TodayView.mutedBackground
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Text("ThoughtJar") // Renamed from "Memory Vault" to match
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(TodayView.darkColor)
                    
                    Spacer()
                    
                    // Gear icon is now a Menu
                    Menu {
                        Button("Set up notifications") {
                            showNotificationSheet = true
                        }
                        // You can add more buttons here in the future
                    } label: {
                        Image(systemName: "gearshape")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(TodayView.darkColor)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                Spacer()
                
                // Show the random thought card only if one is available.
                if let memory = todaysMemory {
                    // --- FIX: Pass the memory to an observing subview ---
                    MemoryDisplayCard(memory: memory)
                } else {
                    Text("Add your first memory in the New Memory tab to get started!")
                        .font(.title)
                        .foregroundColor(TodayView.primaryColor)
                        .padding()
                }
                
                Spacer()
                
            }
        }
        // Add the sheet modifier to present the settings view
        .sheet(isPresented: $showNotificationSheet) {
            NotificationSettingsView()
        }
    }
}

// --- NEW: Observing Subview ---
// This view observes the Memory object, so it will refresh
// automatically when the 'text' or 'date' properties change.
struct MemoryDisplayCard: View {
    @ObservedObject var memory: Memory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Today's random memory")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(TodayView.darkColor)
            
            VStack(alignment: .leading) {
                
                // Wrap the text in a ScrollView to handle long memories
                ScrollView(.vertical, showsIndicators: true) {
                    Text(memory.text ?? "No memory text found.")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(nil)
                        .frame(maxWidth: .infinity, alignment: .leading) // Aligns text to the left
                }
                
                Spacer() // Pushes date to the bottom
                
                // Safely unwrap and format date
                Text("Memory recollection from \(memory.date ?? Date(), formatter: itemFormatter).")
                    .font(.subheadline)
                    .foregroundColor(Color(white: 0.85)) // Off-white for subtitle
                    .padding(.top, 10)
            }
            .padding()
            .frame(maxWidth: .infinity)
            // We set a fixed height here. This ensures the card stays
            // on screen, and if the text is longer, the ScrollView above activates.
            .frame(height: 350)
            .background(TodayView.primaryColor) // Solid primary color background
            // Deep Muted Green overlay for text legibility (applied via background color now)
            .cornerRadius(25)
        }
        .padding(.horizontal)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter
}()
