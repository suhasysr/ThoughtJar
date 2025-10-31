//
//  NewMemoryView.swift
//  Memory Vault
//
//  Created by Suhas Vasu on 9/8/25.
//


import SwiftUI
import CoreData

struct NewMemoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var todaysMemory: Memory? // Binding to the Core Data object
    
    // This property wrapper automatically fetches data from Core Data
    // and updates the view when the data changes.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Memory.date, ascending: false)],
        animation: .default)
    private var memories: FetchedResults<Memory>
    
    @State private var newMemoryText: String = ""
    @State private var editingMemory: Memory? // This will be the Core Data object
    @State private var editedMemoryText: String = ""
    
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
                            // Loop over the FetchedResults
                            ForEach(memories) { memory in
                                MemoryCard(
                                    memory: memory,
                                    onEdit: {
                                        editingMemory = memory
                                        editedMemoryText = memory.text ?? ""
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
                    
                    Button(action: addMemory) { // Updated action
                        Text("Save Memory")
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
            
            // Edit Overlay (now works with a Core Data object)
            if let memoryToEdit = editingMemory {
                EditMemoryOverlay(
                    memory: memoryToEdit,
                    editedText: $editedMemoryText,
                    onSave: {
                        updateMemoryAction(memory: memoryToEdit)
                    },
                    onCancel: {
                        editingMemory = nil // Dismiss overlay
                    }
                )
            }
        }
    }
    
    // --- Core Data CRUD Functions ---
    
    private func addMemory() {
        if newMemoryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return
        }
        
        withAnimation {
            let newMemory = Memory(context: viewContext)
            newMemory.id = UUID()
            newMemory.date = Date()
            newMemory.text = newMemoryText
            
            saveContext()
            newMemoryText = ""
            
            // If this is the very first memory, set it as today's
            if memories.count == 1 {
                todaysMemory = newMemory
                // Save to UserDefaults
                let defaults = UserDefaults.standard
                defaults.set(Date(), forKey: "lastPickDate")
                defaults.set(newMemory.id?.uuidString, forKey: "todaysMemoryID")
            }
        }
    }
    
    private func deleteMemoryAction(memory: Memory) {
        let isTodaysMemory = (todaysMemory?.id == memory.id)
        
        withAnimation {
            viewContext.delete(memory)
            saveContext()
        }
        
        // If the deleted memory was today's, pick a new random one.
        if isTodaysMemory {
            // Fetch all remaining memories
            let request: NSFetchRequest<Memory> = Memory.fetchRequest()
            do {
                let remainingMemories = try viewContext.fetch(request)
                todaysMemory = remainingMemories.randomElement() // Pick a new one
                
                // Update UserDefaults
                let defaults = UserDefaults.standard
                defaults.set(Date(), forKey: "lastPickDate")
                defaults.set(todaysMemory?.id?.uuidString, forKey: "todaysMemoryID")
                
            } catch {
                print("Failed to fetch after delete: \(error)")
                todaysMemory = nil
            }
        }
    }
    
    private func updateMemoryAction(memory: Memory) {
        withAnimation {
            memory.text = editedMemoryText
            saveContext()
            
            // If the edited memory was the "Today's Memory", update it.
            if todaysMemory?.id == memory.id {
                todaysMemory = memory
            }
            editingMemory = nil // Dismiss overlay
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}


// MARK: - Helper Views

// The card view for displaying each individual memory.
struct MemoryCard: View {
    @ObservedObject var memory: Memory // Use @ObservedObject for Core Data objects
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(memory.text ?? "Empty Memory") // Safely unwrap
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
            
            Text(memory.date ?? Date(), formatter: itemFormatter) // Use a formatter
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
    @ObservedObject var memory: Memory
    @Binding var editedText: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea().onTapGesture(perform: onCancel)
            
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
                
                HStack {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray)
                            .cornerRadius(10)
                    }
                    
                    Button(action: onSave) {
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 10)
            .padding(25)
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

//// Preview provider for Xcode's Canvas
//struct NewMemoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewMemoryView()
//    }
//}
