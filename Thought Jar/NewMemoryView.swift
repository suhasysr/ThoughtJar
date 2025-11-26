//
//  NewMemoryView.swift
//  Memory Vault
//
//  Created by Suhas Vasu on 9/8/25.
//


import SwiftUI
import CoreData

// MARK: - Main View
struct NewMemoryView: View {
    
    // --- PROPERTIES ---
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var todaysMemory: Memory? // Binding to the Core Data object
    
    // This property wrapper automatically fetches data from Core Data
    // and updates the view when the data changes.
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.date, order: .reverse)], // Default: Sort by last added
        animation: .default)
    private var memories: FetchedResults<Memory>
    
    @State private var newMemoryText: String = ""
    @State private var editingMemory: Memory? // This will be the Core Data object
    @State private var editedMemoryText: String = ""
    
    // Tracks if the TextEditor is active (for keyboard and layout)
    @FocusState private var isEditorFocused: Bool

    // --- COLOR DEFINITIONS ---
    static let mutedBackground = Color(hex: 0xE5E7E4)
    static let primaryColor = Color(hex: 0x4A6D63)
    static let darkColor = Color(hex: 0x2C3E50)
    static let cardHighlight = Color(hex: 0xD4DAD3)
    
    // --- SORTING ---
    private enum SortType {
        case alphabetical
        case lastAdded
        case firstAdded
        
        // This creates the correct SortDescriptor for Core Data
        var descriptors: [SortDescriptor<Memory>] {
            switch self {
            case .alphabetical:
                // Sorts A -> Z (forward)
                return [SortDescriptor(\.text, order: .forward)]
            case .lastAdded:
                // Sorts newest -> oldest (reverse)
                return [SortDescriptor(\.date, order: .reverse)]
            case .firstAdded:
                // Sorts oldest -> newest (forward)
                return [SortDescriptor(\.date, order: .forward)]
            }
        }
    }
    
    // --- BODY ---
    
    var body: some View {
        ZStack {
            // Use the soft background
            NewMemoryView.mutedBackground
                .ignoresSafeArea()
                .onTapGesture {
                    // Dismiss keyboard if user taps anywhere on the background
                    isEditorFocused = false
                }

            // Scrollable content area
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading) {
                    
                    // --- Header ---
                    HStack {
                        //                        Image(systemName: "arrow.backward")
                        //                            .resizable()
                        //                            .frame(width: 20, height: 15)
                        //                            .foregroundColor(NewMemoryView.darkColor)
                        //                            .padding(.leading)
                        
                        Text("New Memory")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(NewMemoryView.darkColor)
                            .padding(.leading)
                        //                        Spacer()
                        //                        Image(systemName: "ellipsis")
                        //                            .resizable()
                        //                            .frame(width: 20, height: 5)
                        //                            .foregroundColor(NewMemoryView.darkColor)
                        //                            .rotationEffect(.degrees(90))
                        //                            .padding(.trailing)
                    }
                    .padding(.top)
                    .onTapGesture {
                        isEditorFocused = false // Dismiss keyboard if user taps header
                    }

                    // --- Recent Memories (Hides when keyboard is active) ---
                    if !isEditorFocused {
                        VStack(alignment: .leading) {
                            
                            // This is now an HStack to hold the title and menu
                            HStack {
                                Text("Recent Memories")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(NewMemoryView.darkColor)
                                    .onTapGesture {
                                        isEditorFocused = false
                                    }
                                
                                Spacer() // Pushes the menu to the right
                                
                                // --- NEW SORT MENU ---
                                Menu {
                                    Button("Sort alphabetically") {
                                        memories.sortDescriptors = SortType.alphabetical.descriptors
                                    }
                                    Button("Sort by last added") {
                                        memories.sortDescriptors = SortType.lastAdded.descriptors
                                    }
                                    Button("Sort by first added") {
                                        memories.sortDescriptors = SortType.firstAdded.descriptors
                                    }
                                } label: {
                                    Image(systemName: "ellipsis")
                                        .font(.callout)
                                        .foregroundColor(NewMemoryView.darkColor)
                                        .padding(8)
                                        .contentShape(Rectangle())
                                }
                                .rotationEffect(.degrees(90)) // Makes the ellipsis vertical
                                // --- END OF NEW SORT MENU ---
                            }
                            .padding(.horizontal)
                            .padding(.top)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
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
                    } // End Conditional "Recent Memories"

                    // --- New Thought Input Area ---
                    VStack(alignment: .leading) {
                        Text("What's on your mind?")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(NewMemoryView.darkColor)
                            .padding(.horizontal)
                            .padding(.top)
                            .onTapGesture {
                                isEditorFocused = false // Dismiss keyboard if user taps title
                            }
                        
                        // TextEditor and its placeholder/minimize button
                        ZStack(alignment: .topLeading) {
                            
                            TextEditor(text: $newMemoryText)
                                // Expands height when focused
                                .frame(height: isEditorFocused ? UIScreen.main.bounds.height * 0.4 : 150)
                                .padding(10)
                                .scrollContentBackground(.hidden)
                                .background(NewMemoryView.cardHighlight)
                                // --- FIX 1: Force text color to be dark ---
                                .foregroundColor(NewMemoryView.darkColor)
                                .cornerRadius(10)
                                .focused($isEditorFocused) // Binds focus to the state
                                .overlay(
                                    // Visual highlight when focused
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(isEditorFocused ? NewMemoryView.primaryColor : Color.clear, lineWidth: 2)
                                )
                            
                            // Custom "I want to remember..." Placeholder
                            if newMemoryText.isEmpty {
                                Text("I want to remember ...")
                                    .font(.body)
                                    .foregroundColor(NewMemoryView.darkColor.opacity(0.4))
                                    .padding(.leading, 15)
                                    .padding(.top, 18)
                                    .allowsHitTesting(false) // Lets taps pass through
                            }
                            
                            // Minimize Keyboard Button
                            if isEditorFocused {
                                HStack {
                                    Spacer()
                                    Button {
                                        isEditorFocused = false // Removes focus
                                    } label: {
                                        Image(systemName: "keyboard.chevron.compact.down")
                                            .font(.title3)
                                            .padding(8)
                                            .foregroundColor(NewMemoryView.darkColor)
                                            .background(Color.white.opacity(0.5))
                                            .clipShape(Circle())
                                    }
                                    .padding(.top, 5)
                                    .padding(.trailing, 5)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5)
                        // Animate the height change
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isEditorFocused)

                    } // End Input VStack

                } // End ScrollView's main VStack
                .padding(.bottom, 100) // Space for the floating button
            
            } // End ScrollView
            
            // --- Floating Save Button (Stays above keyboard) ---
            VStack {
                Spacer()
                Button(action: addMemory) {
                    Text("Save Memory")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(NewMemoryView.primaryColor)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                .ignoresSafeArea(.keyboard, edges: .bottom)
            } // End Floating Button VStack
            
            // --- Edit Overlay (Shown when editingMemory is not nil) ---
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
            
            isEditorFocused = false // Dismiss keyboard on save
            
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

// MARK: - Helper View: MemoryCard
struct MemoryCard: View {
    @ObservedObject var memory: Memory // Use @ObservedObject for Core Data objects
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(memory.text ?? "Empty Memory") // Safely unwrap
                    .font(.body)
                    .foregroundColor(NewMemoryView.darkColor)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                // Edit Icon
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(NewMemoryView.primaryColor)
                }
                .buttonStyle(PlainButtonStyle()) // To prevent unwanted button styling
                
                // Delete Icon
                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.red.opacity(0.7)) // A slightly muted red
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Spacer()
            
            Text(memory.date ?? Date(), formatter: itemFormatter) // Use a formatter
                .font(.caption)
                .foregroundColor(NewMemoryView.primaryColor.opacity(0.7))
        }
        .padding()
        .frame(width: 160, height: 180)
        .background(NewMemoryView.cardHighlight)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

// MARK: - Helper View: EditMemoryOverlay
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
                    .foregroundColor(NewMemoryView.darkColor)
                
                TextEditor(text: $editedText)
                    .frame(height: 150)
                    .padding(8)
                    .scrollContentBackground(.hidden)
                    // CHANGED: Ensure this uses your app's color,
                    // not a system default like .systemGray5
                    .background(NewMemoryView.cardHighlight)
                    // --- FIX 2: Force text color to be dark ---
                    .foregroundColor(NewMemoryView.darkColor)
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
                            .background(NewMemoryView.primaryColor)
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

// MARK: - Formatters & Extensions

// Date formatter (fileprivate to keep it private to this file)
fileprivate let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter
}()

