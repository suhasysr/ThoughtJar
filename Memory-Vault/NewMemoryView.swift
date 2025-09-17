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
    
    @Binding var todaysMemory: Memory? // Binding to update the today's memory if needed
    @State private var editingMemory: Memory? // Holds the memory being edited
    @State private var editedMemoryText: String = "" // Holds the text in the edit field
    
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6) // Consistent background color
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    
                    Text("New Memory")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.blue)
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
                
                VStack(alignment: .leading) {
                    Text("Recent Memories")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(memoryData.memories) { memory in
                                MemoryCard(
                                    memory: memory,
                                    onEdit: {
                                        editingMemory = memory
                                        editedMemoryText = memory.text
                                    },
                                    onDelete: {
                                        deleteMemoryAction(memory: memory)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("What's on your mind?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    TextEditor(text: $newMemoryText)
                        .frame(height: 150) // Adjust height as needed
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            Text(newMemoryText.isEmpty ? "I want to remember..." : "")
                                .foregroundColor(.gray)
                                .padding(.leading, 14)
                                .padding(.top, 8)
                                .opacity(newMemoryText.isEmpty ? 1 : 0),
                            alignment: .topLeading
                        )
                        .padding(.horizontal)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5)
                    
                    Button(action: {
                        if !newMemoryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            memoryData.addMemory(text: newMemoryText)
                            newMemoryText = "" // Clear the text field after saving
                            // If there was no todaysMemory, pick the new one.
                            if todaysMemory == nil {
                                todaysMemory = memoryData.memories.first
                            }
                        }
                    }) {
                        Text("Save Memory") // Updated text
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
                
                Spacer()
            }
            
            // Full-screen overlay for editing a memory
            if let memoryToEdit = editingMemory {
                EditMemoryOverlay(
                    memory: memoryToEdit,
                    editedText: $editedMemoryText,
                    onSave: {
                        var updatedMemory = memoryToEdit
                        updatedMemory.text = editedMemoryText
                        memoryData.updateMemory(memory: updatedMemory)
                        
                        // If the edited memory was the "Today's Memory", update it.
                        if todaysMemory?.id == updatedMemory.id {
                            todaysMemory = updatedMemory
                        }
                        editingMemory = nil // Dismiss overlay
                    },
                    onCancel: {
                        editingMemory = nil // Dismiss overlay
                    }
                )
            }
        }
    }
    
    // Helper function to handle memory deletion logic
    private func deleteMemoryAction(memory: Memory) {
        let isTodaysMemory = (todaysMemory?.id == memory.id)
        
        memoryData.deleteMemory(memoryId: memory.id)
        
        // If the deleted memory was today's, pick a new random one.
        if isTodaysMemory {
            todaysMemory = memoryData.memories.randomElement()
        }
    }
}


// MARK: - Helper Views and Models

// Custom view for displaying a single memory card
struct MemoryCard: View {
    let memory: Memory
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(memory.text)
                    .font(.body)
                    .foregroundColor(.black)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                // Edit Icon
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle()) // To prevent unwanted button styling
                
                // Delete Icon
                Button(action: onDelete) {
                    Image(systemName: "trash.circle")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Spacer()
            
            Text(memory.date)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 160, height: 180) // Fixed size for the cards
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

// Overlay for editing a memory
struct EditMemoryOverlay: View {
    let memory: Memory
    @Binding var editedText: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea() // Dim background
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Edit Memory")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                TextEditor(text: $editedText)
                    .frame(height: 150)
                    .padding(8)
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                HStack {
                    Spacer()
                    Button("Cancel", action: onCancel)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(5)
                    
                    Button(action: onSave) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        Text("Save")
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(5)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 10)
            .padding(25) // Inset from edges
        }
    }
}

// Preview provider for Xcode's Canvas.
struct NewThoughtView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide a dummy MemoryData and a constant binding for preview.
        NewMemoryView(memoryData: MemoryData(), todaysMemory: .constant(nil))
    }
}

//// Preview provider for Xcode's Canvas
//struct NewMemoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewMemoryView()
//    }
//}
