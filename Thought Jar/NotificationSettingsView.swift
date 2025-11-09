//
//  NotificationSettingsView.swift
//  Thought Jar
//
//  Created by Suhas Vasu on 11/8/25.
//

import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    // --- State Properties ---
    @State private var frequency: ReminderFrequency = .daily
    @State private var reminderTime: Date = Date()
    @State private var selectedWeekday: Int = 1 // 1 = Sunday
    
    // --- UserDefaults Keys ---
    private let freqKey = "notificationFrequency"
    private let timeKey = "notificationTime"
    private let weekdayKey = "notificationWeekday"
    
    // --- App Theme Colors ---
    static let mutedBackground = Color(hex: 0xE5E7E4)
    static let primaryColor = Color(hex: 0x4A6D63)
    static let darkColor = Color(hex: 0x2C3E50)
    static let cardHighlight = Color(hex: 0xD4DAD3)
    
    // Helper to get weekday names for the picker
    private var weekdaySymbols: [String] {
        Calendar.current.weekdaySymbols
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main background
                NotificationSettingsView.mutedBackground
                    .ignoresSafeArea()
                
                Form {
                    // --- FREQUENCY SECTION ---
                    Section(header: Text("Frequency").foregroundColor(NotificationSettingsView.darkColor.opacity(0.8))) {
                        
                        // Picker (no custom label needed, segmented style is fine)
                        Picker("Remind Me", selection: $frequency) {
                            ForEach(ReminderFrequency.allCases) { freq in
                                Text(freq.displayName).tag(freq)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(NotificationSettingsView.primaryColor)
                        
                        // --- FIX: Custom Label for Weekday Picker ---
                        if frequency == .weekly {
                            HStack {
                                // Our OWN Text label that we can color
                                Text("Day of Week")
                                    .foregroundColor(NotificationSettingsView.darkColor)
                                Spacer()
                                Picker("Day of Week", selection: $selectedWeekday) {
                                    ForEach(1...7, id: \.self) { day in
                                        Text(weekdaySymbols[day - 1]).tag(day)
                                    }
                                }
                                .labelsHidden() // Hide the default (white) label
                                .tint(NotificationSettingsView.primaryColor)
                            }
                        }
                    }
                    .listRowBackground(NotificationSettingsView.cardHighlight)
                    
                    // --- TIME SECTION ---
                    Section(header: Text("Time").foregroundColor(NotificationSettingsView.darkColor.opacity(0.8))) {
                        
                        // Custom Label for DatePicker
                        HStack {
                            Text("Time")
                                .foregroundColor(NotificationSettingsView.darkColor)
                            Spacer()
                        }
                        
                        DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .tint(NotificationSettingsView.primaryColor)
                        
                        // --- NEW FIX FOR DATEPICKER ---
                        // This inverts the (white) text to black,
                        // then multiplies it by our dark color.
                            .colorInvert()
                            .colorMultiply(NotificationSettingsView.darkColor)
                        // --- END OF FIX ---
                    }
                    .listRowBackground(NotificationSettingsView.cardHighlight)
                    
                    // --- SET REMINDER BUTTON ---
                    Section {
                        // --- FIX: Use a custom Text label inside the Button ---
                        Button(action: saveSettingsAndSchedule) {
                            Text("Set Reminder")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(NotificationSettingsView.primaryColor) // Color our Text
                        }
                    }
                    .listRowBackground(NotificationSettingsView.cardHighlight)
                    
                    // --- DISABLE REMINDERS BUTTON ---
                    Section {
                        // --- FIX: Use a custom Text label inside the Button ---
                        Button(action: {
                            NotificationManager.shared.cancelAllNotifications()
                            dismiss()
                        }) {
                            Text("Disable Reminders")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.red) // Color our Text
                        }
                    }
                    .listRowBackground(NotificationSettingsView.cardHighlight)
                }
                .scrollContentBackground(.hidden) // Hides default system background
                .navigationTitle("Notifications")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
        }
        .tint(NotificationSettingsView.primaryColor) // Sets tint for "Cancel" button
        .onAppear(perform: loadSettings)
    }
    
    /// Load saved settings from UserDefaults when the view appears
    func loadSettings() {
        let defaults = UserDefaults.standard
        
        if let savedFreqRaw = defaults.string(forKey: freqKey),
           let savedFreq = ReminderFrequency(rawValue: savedFreqRaw) {
            self.frequency = savedFreq
        }
        
        if let savedTimeInterval = defaults.object(forKey: timeKey) as? TimeInterval {
            self.reminderTime = Date(timeIntervalSince1970: savedTimeInterval)
        }
        
        let savedWeekday = defaults.integer(forKey: weekdayKey)
        if savedWeekday >= 1 && savedWeekday <= 7 {
            self.selectedWeekday = savedWeekday
        } else {
            self.selectedWeekday = Calendar.current.component(.weekday, from: Date())
        }
    }
    
    /// Save settings to UserDefaults and schedule the notification
    func saveSettingsAndSchedule() {
        let defaults = UserDefaults.standard
        defaults.set(frequency.rawValue, forKey: freqKey)
        defaults.set(reminderTime.timeIntervalSince1970, forKey: timeKey)
        
        if frequency == .weekly {
            defaults.set(selectedWeekday, forKey: weekdayKey)
        }
        
        NotificationManager.shared.scheduleNotification(
            frequency: frequency,
            time: reminderTime,
            weekday: selectedWeekday
        )
        
        dismiss()
    }
}

//#Preview {
//    NotificationSettingsView()
//}
