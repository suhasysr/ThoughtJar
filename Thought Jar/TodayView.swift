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
                    Text("Thought Jar") // Renamed from "Memory Vault" to match
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(TodayView.darkColor)
                    
                    Spacer()
                    
                    // --- MODIFIED: Gear icon is now a Menu ---
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
                    // --- End of modification ---
                }
                .padding(.horizontal)
                .padding(.top)
                
                Spacer()
                
                // Show the random thought card only if one is available.
                if let memory = todaysMemory {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Today's random memory")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(TodayView.darkColor)
                        
                        ZStack {
                            // Keep the art, but apply a subtle tint for a cohesive look
                            Image("mountain_art")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .clipped()
                                .cornerRadius(25)
                                .overlay(
                                    // Subtle overlay to cool down the image tones
                                    TodayView.primaryColor.opacity(0.1)
                                        .cornerRadius(25)
                                )
                            
                            VStack(alignment: .leading) {
                                // Safely unwrap text
                                Text(memory.text ?? "No memory text found.")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .lineLimit(nil)
                                
                                // Safely unwrap and format date
                                Text("Memory recollection from \(memory.date ?? Date(), formatter: itemFormatter).")
                                    .font(.subheadline)
                                    .foregroundColor(Color(white: 0.85)) // Off-white for subtitle
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            // Deep Muted Green overlay for text legibility
                            .background(TodayView.primaryColor.opacity(0.8))
                            .cornerRadius(25)
                        }
                    }
                    .padding(.horizontal)
                } else {
                    Text("Add your first memory in the New Memory tab to get started!")
                        .font(.title)
                        .foregroundColor(TodayView.primaryColor)
                        .padding()
                }
                
                Spacer()
                
            }
        }
        // --- NEW ---
        // Add the sheet modifier to present the settings view
        .sheet(isPresented: $showNotificationSheet) {
            NotificationSettingsView()
        }
    }
}

// A helper for formatting dates
private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter
}()

// Preview provider for Xcode's Canvas.
//struct TodayView_Previews: PreviewProvider {
//    static var previews: some View {
//        TodayView()
//    }
//}
