//
//  TodayView.swift
//  Memory Vault
//
//  Created by Suhas Vasu on 9/7/25.
//


import SwiftUI

// Main view for the "Today's Memory" screen.
struct TodayView: View {
    
    // This view now receives the single, pre-selected random thought.
    let todaysMemory: Memory?
    
    var body: some View {
        // Use a ZStack to layer the content over the background color.
        ZStack {
            Color(UIColor.systemGray6)
                .ignoresSafeArea()
            
            //            VStack {
            //                // Top navigation bar with app name and settings icon.
            //                HStack {
            //                    Text("Memory Vault")
            //                        .font(.system(size: 24, weight: .bold))
            //                        .foregroundColor(.black)
            //
            //                    Spacer()
            //
            //                    Image(systemName: "gearshape")
            //                        .resizable()
            //                        .frame(width: 25, height: 25)
            //                        .foregroundColor(.black)
            //                }
            //                .padding(.horizontal)
            //                .padding(.top)
            //
            //                Spacer() // Pushes the content to the center.
            //
            //                // Card view for "Today's Random memory".
            //                VStack(alignment: .leading, spacing: 10) {
            //                    Text("Today's random memory")
            //                        .font(.title)
            //                        .fontWeight(.bold)
            //                        .foregroundColor(.black)
            //
            //                    // The main content of today's memory card.
            //                    ZStack {
            //                        // Background image for the card.
            //                        Image("mountain_art") // You will need to add this image to your Asset Catalog.
            //                            .resizable()
            //                            .aspectRatio(contentMode: .fill)
            //                            .frame(height: 250)
            //                            .clipped()
            //                            .cornerRadius(25)
            //
            //                        // Text overlay with a semi-transparent black background.
            //                        VStack(alignment: .leading) {
            //                            Text(todaysMemory?.text)
            //                                .font(.largeTitle)
            //                                .fontWeight(.bold)
            //                                .foregroundColor(.white)
            //                                .lineLimit(nil)
            //
            //                        }
            //                        .padding()
            //                        .frame(maxWidth: .infinity, alignment: .leading)
            //                        .background(Color.black.opacity(0.3)) // Semi-transparent overlay.
            //                        .cornerRadius(25)
            //                    }
            //                }
            //                .padding(.horizontal)
            //
            //                Spacer() // Pushes the content to the center.
            //
            //            }
            
            VStack {
                HStack {
                    Text("Memory Vault")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    
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
                                Text(memory.text)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .lineLimit(nil)
                                
                                Text("Memory recollection from \(memory.date).")
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
                    // Display a message if no thoughts have been entered yet.
                    Text("Enter a memory to get started!")
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Spacer()
                
            }
        }
    }
}

// Preview provider for Xcode's Canvas.
//struct TodayView_Previews: PreviewProvider {
//    static var previews: some View {
//        TodayView()
//    }
//}
