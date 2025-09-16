//
//  NewMemoryView.swift
//  Memory Vault
//
//  Created by Suhas Vasu on 9/8/25.
//


import SwiftUI

struct NewMemoryView: View {
    @ObservedObject var memoryData: MemoryData
    @State private var newMemoryText: String = "" // State variable for the new memory input
    
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6) // Consistent background color
                .ignoresSafeArea()
            
            VStack {
                // Top navigation bar
                HStack {
                    
                    Text("New Memory")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.leading)
                    
                    Spacer()
                    
                    Image(systemName: "ellipsis") // Options icon
                        .resizable()
                        .frame(width: 20, height: 5)
                        .foregroundColor(.black)
                        .rotationEffect(.degrees(90)) // Rotate to make it vertical
                        .padding(.trailing)
                }
                .padding(.top)
                
                // Saved Memories Section
                VStack(alignment: .leading) {
                    Text("Recent Memories")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    // Horizontal scroll view for the memory cards.
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(memoryData.memories) { memory in
                                MemoryCard(memory: memory)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .frame(height: 200)
                }
                
                // Section to input another memory
                VStack(alignment: .leading) {
                    Text("What's on your mind?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    // Text editor for new memory with placeholder
                    TextEditor(text: $newMemoryText)
                        .frame(height: 150) // Adjust height as needed
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            Text(newMemoryText.isEmpty ? "I want to remember..." : "")
                                .foregroundColor(.gray)
                                .padding(.leading, 15)
                                .padding(.top, 10),
                            alignment: .topLeading
                        )
                        .padding(.horizontal)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5) // Subtle shadow
                    
                    Button(action: {
                        // Use the shared data model to add the new thought.
                        memoryData.addThought(text: newMemoryText)
                        newMemoryText = ""
                    }) {
                        Text("Save Thought")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                }
                
                Spacer() // Pushes content upwards
                
            }
        }
    }
}



// Custom view for displaying a single memory card
struct MemoryCard: View {
    let memory: Memory
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(memory.text)
                .font(.body)
                .foregroundColor(.black)
                .lineLimit(4) // Limit lines to fit in the card
                .fixedSize(horizontal: false, vertical: true) // Allow text to wrap vertically
            
            Spacer()
            
            Text(memory.date)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 160, height: 180) // Fixed size for the cards
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5) // Subtle shadow
    }
}

//// Preview provider for Xcode's Canvas
//struct NewMemoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewMemoryView()
//    }
//}
