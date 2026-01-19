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
    
    // --- AppStorage for Tooltip ---
    @AppStorage("hasSeenSortTooltip") private var hasSeenSortTooltip: Bool = false

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
            VStack(alignment: .leading, spacing: 0) {
                
                // --- Header ---
                HStack {
                    Text("New Thought")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(NewMemoryView.darkColor)
                        .padding(.leading)
                    Spacer()
                }
                .padding(.top)
                .padding(.bottom, 10) // Space below header
                .onTapGesture {
                    isEditorFocused = false // Dismiss keyboard if user taps header
                }

                // --- New Thought Input Area (Moved to Top) ---
                VStack(alignment: .leading) {
                    Text("What's on your mind?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(NewMemoryView.darkColor)
                        .padding(.horizontal)
                        .padding(.top, 30) // Added top padding for spacing
                        .onTapGesture {
                            isEditorFocused = false // Dismiss keyboard if user taps title
                        }
                    
                    // TextEditor and its placeholder/minimize button
                    ZStack(alignment: .topLeading) {
                        
                        TextEditor(text: $newMemoryText)
                            // Expands height when focused
                            .frame(height: isEditorFocused ? UIScreen.main.bounds.height * 0.35 : 150)
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
                    
                    // --- Save Button (Moved Below Input Area) ---
                    Button(action: addMemory) {
                        Text("Deposit Thought")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(NewMemoryView.primaryColor)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                } // End Input VStack
                .padding(.bottom, 20)

                Spacer() // This pushes the Recent Memories section to the bottom

                // --- Recent Memories (Hides when keyboard is active) ---
                if !isEditorFocused {
                    VStack(alignment: .leading) {
                        
                        // This is now an HStack to hold the title and menu
                        HStack {
                            Text("Recent Thoughts")
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
                                // FIXED JITTER: Rotate image inside the frame, stable container
                                Image(systemName: "ellipsis")
                                    .font(.callout)
                                    .rotationEffect(.degrees(90))
                                    .foregroundColor(NewMemoryView.darkColor)
                                    .frame(width: 44, height: 44) // Fixed touch target size
                                    .contentShape(Rectangle())
                            }
                            // Removed external padding/rotation to prevent layout shift
                        }
                        // --- UPDATED TOOLTIP LOGIC ---
                        .overlay(alignment: .bottomTrailing) {
                            if !hasSeenSortTooltip {
                                SortTooltipView(onDismiss: {
                                    hasSeenSortTooltip = true
                                })
                                .offset(x: 0, y: -45)
                                .zIndex(1)
                            }
                        }
                        // Set standard horizontal padding to 20 to strictly control alignment
                        .padding(.horizontal, 20)
                        .padding(.bottom, 5)

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
                } else {
                    Spacer() // Pushes input area to top when focused
                }

            } // End Main VStack
            
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
            
            // --- FIX FOR UI REFLECTION ---
            if todaysMemory?.id == memory.id {
                let current = todaysMemory
                todaysMemory = nil
                todaysMemory = current
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

// --- NEW: Tooltip View for Sorting ---
struct SortTooltipView: View {
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .trailing, spacing: -2) { // Negative spacing to merge shapes
            // Bubble
            Text("Sort your previously entered thoughts")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading) // Ensure readable wrapping
                .padding(12)
                .background(NewMemoryView.primaryColor)
                .cornerRadius(10)
                // Removed shadow from here
                .frame(maxWidth: 280, alignment: .trailing) // Increased width, aligned right
                .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
                .onTapGesture {
                    withAnimation { onDismiss() }
                }
            
            // Small Arrow pointing down
            Image(systemName: "arrowtriangle.down.fill")
                .resizable()
                .frame(width: 15, height: 10)
                .foregroundColor(NewMemoryView.primaryColor)
                // ALIGNMENT FIX:
                // Menu Icon Center: 20 (Stack Padding) + 22 (Half Icon Width) = 42pts from Right Edge
                // Arrow Width: 15pts (Half is 7.5pts)
                // To align centers: Padding + 7.5 = 42
                // Padding = 42 - 7.5 = 34.5
                .padding(.trailing, 14.5)
                // Note: The overlay is on the HStack which has 20 padding.
                // So the tooltip right edge is at "Screen Right - 20".
                // We want arrow center at "Screen Right - 42".
                // So relative to Tooltip edge: 22pts.
                // X + 7.5 = 22 => X = 14.5
        }
        // Apply shadow to the combined shape so they look like one piece
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
    }
}

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
