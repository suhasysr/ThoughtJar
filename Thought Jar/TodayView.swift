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
    
    // --- NEW: AppStorage for Tooltip ---
    // This persists across app launches. false = hasn't seen it yet.
    @AppStorage("hasSeenSettingsTooltip") private var hasSeenSettingsTooltip: Bool = false

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
                .padding(.horizontal) // Standard padding (approx 16pts)
                .padding(.top)
                // --- NEW: ZIndex for Tooltip relative positioning ---
                .zIndex(1)
                
                Spacer()
                
                // Show the random thought card only if one is available.
                if let memory = todaysMemory {
                    // We extract the card into a subview that has @ObservedObject
                    // to ensure it updates instantly when edited in another tab.
                    ObservingMemoryCard(memory: memory)
                } else {
                    Text("Add your first thought in the New Thought tab to get started!")
                        .font(.title)
                        .foregroundColor(TodayView.primaryColor)
                        .padding()
                }
                
                Spacer()
            }
            
            // --- NEW: Tooltip Overlay ---
            if !hasSeenSettingsTooltip {
                TooltipOverlay(onDismiss: {
                    hasSeenSettingsTooltip = true
                })
            }
        }
        // Add the sheet modifier to present the settings view
        .sheet(isPresented: $showNotificationSheet) {
            NotificationSettingsView()
        }
    }
}

// --- NEW: Tooltip View ---
struct TooltipOverlay: View {
    let onDismiss: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                // Dimmed background (optional, or just invisible catch-all)
                Color.black.opacity(0.01)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { onDismiss() }
                    }
                
                VStack(alignment: .trailing, spacing: 0) {
                    // Small Arrow pointing up
                    Image(systemName: "arrowtriangle.up.fill")
                        .resizable()
                        .frame(width: 15, height: 10)
                        .foregroundColor(TodayView.primaryColor)
                        // ALIGNMENT CALCULATION:
                        // Gear Icon is at: ScreenEdge - 16 (HStack pad) - 12.5 (Half Icon) = 28.5 from right
                        // VStack is at: ScreenEdge - 16 (VStack pad)
                        // Arrow needs to be centered at 12.5 from VStack right edge.
                        // Arrow width is 15 (Half is 7.5).
                        // Padding needed = 12.5 - 7.5 = 5.
                        .padding(.trailing, 5)
                    
                    // Bubble
                    Text("Set daily or weekly reminders to peek into your thoughts")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(TodayView.primaryColor)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .frame(maxWidth: 200)
                }
                .padding(.top, 60) // Adjust based on header height
                .padding(.trailing, 16) // Match the horizontal padding of the main view
                .transition(.opacity.combined(with: .scale))
            }
        }
    }
}

// --- NEW: Observing Subview for Memory ---
struct ObservingMemoryCard: View {
    @ObservedObject var memory: Memory // Keeps UI in sync with Core Data updates
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Today's random thought")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(TodayView.darkColor)
            
            VStack(alignment: .leading) {
                
                // Wrap the text in a ScrollView to handle long memories
                ScrollView(.vertical, showsIndicators: true) {
                    Text(memory.text ?? "No thought found.")
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
