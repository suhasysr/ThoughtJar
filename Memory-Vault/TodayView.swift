//
//  TodayView.swift
//  Memory Vault
//
//  Created by Suhas Vasu on 9/7/25.
//


import SwiftUI

struct TodayView: View {
    let todaysMemory: Memory? // Make it @ObservedObject
    
    var body: some View {
        // Use a ZStack to layer the content over the background color.
        ZStack {
            Color(UIColor.systemGray6)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Text("Memory Vault")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Image(systemName: "gearshape")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.black)
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
                            .foregroundColor(.black)
                        
                        ZStack {
                            Image("mountain_art")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .clipped()
                                .cornerRadius(25)
                            
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
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(25)
                        }
                    }
                    .padding(.horizontal)
                } else {
                    Text("Add your first memory in the New Memory tab to get started!")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Spacer()
                
            }
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
