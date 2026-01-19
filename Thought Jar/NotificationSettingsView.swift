//
//  NotificationSettingsView.swift
//  Thought Jar
//
//  Created by Suhas Vasu on 11/8/25.
//

import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {

    @Environment(\.presentationMode) var presentationMode

    // --- Properties for "Peek" Notification ---
    @State private var reminderTime = Date()
    @State private var frequency = "Daily"
    let frequencies = ["Daily", "Weekly"]

    // Day of week selection: 1 = Sunday, 7 = Saturday (Calendar compatible)
    @State private var selectedWeekday = 1

    // --- Properties for "Inactivity" Notification ---
    // Defaults to true if key is missing
    @AppStorage("inactivityReminderEnabled") private var inactivityReminderEnabled: Bool = true

    // Color Definitions (Matching the App Theme)
    static let mutedBackground = Color(hex: 0xE5E7E4)
    static let primaryColor = Color(hex: 0x4A6D63)
    static let darkColor = Color(hex: 0x2C3E50)
    static let cardHighlight = Color(hex: 0xD4DAD3)

    var body: some View {
        ZStack {
            NotificationSettingsView.mutedBackground
                .ignoresSafeArea()

            VStack(spacing: 25) {
                // --- Header ---
                Text("Notification Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(NotificationSettingsView.darkColor)
                    .padding(.top, 20)

                // --- Section 1: Reminder to View Thoughts ---
                VStack(alignment: .leading, spacing: 15) {
                    Text("Peek into your thoughts")
                        .font(.headline)
                        .foregroundColor(NotificationSettingsView.darkColor)

                    Divider()

                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(NotificationSettingsView.primaryColor)
                        DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .colorInvert()
                            .colorMultiply(NotificationSettingsView.darkColor)
                    }
                    .padding(.vertical, 5)

                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(NotificationSettingsView.primaryColor)
                        Text("Frequency")
                            .foregroundColor(NotificationSettingsView.darkColor)
                        Spacer()
                        Picker("Frequency", selection: $frequency) {
                            ForEach(frequencies, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .accentColor(NotificationSettingsView.primaryColor)
                    }

                    // Show Day Picker only if Weekly is selected
                    if frequency == "Weekly" {
                        HStack {
                            Image(systemName: "calendar.day.timeline.left")
                                .foregroundColor(NotificationSettingsView.primaryColor)
                            Text("Day")
                                .foregroundColor(NotificationSettingsView.darkColor)
                            Spacer()
                            Picker("Day", selection: $selectedWeekday) {
                                Text("Sunday").tag(1)
                                Text("Monday").tag(2)
                                Text("Tuesday").tag(3)
                                Text("Wednesday").tag(4)
                                Text("Thursday").tag(5)
                                Text("Friday").tag(6)
                                Text("Saturday").tag(7)
                            }
                            .pickerStyle(MenuPickerStyle())
                            .accentColor(NotificationSettingsView.primaryColor)
                        }
                    }

                    // Horizontal Buttons for Set / Disable
                    HStack(spacing: 15) {
                        Button(action: schedulePeekNotification) {
                            Text("Set")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(NotificationSettingsView.primaryColor)
                                .cornerRadius(10)
                        }

                        Button(action: cancelPeekNotification) {
                            Text("Disable")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red.opacity(0.7))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.top, 10)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5)
                .padding(.horizontal)

                // --- Section 2: Reminder to Add New Thoughts ---
                VStack(alignment: .leading, spacing: 15) {
                    Text("Add new thought")
                        .font(.headline)
                        .foregroundColor(NotificationSettingsView.darkColor)

                    Divider()

                    Text("We send a friendly nudge if you haven't added a thought in 7 days.")
                        .font(.subheadline)
                        .foregroundColor(NotificationSettingsView.darkColor.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.vertical, 5)

                    if inactivityReminderEnabled {
                        Button(action: deleteInactivityNotification) {
                            Text("Delete Reminder")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red.opacity(0.7))
                                .cornerRadius(10)
                        }
                    } else {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(NotificationSettingsView.primaryColor)
                            Text("Reminder disabled")
                                .font(.subheadline)
                                .foregroundColor(NotificationSettingsView.darkColor)
                            Spacer()
                            Button("Enable") {
                                // Re-enable and start the counter immediately
                                inactivityReminderEnabled = true
                                scheduleInactivityNotification()
                                presentationMode.wrappedValue.dismiss()
                            }
                            .foregroundColor(NotificationSettingsView.primaryColor)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(NotificationSettingsView.mutedBackground)
                        .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5)
                .padding(.horizontal)

                Spacer()
            }
        }
    }

    // --- Logic for Section 1 (Peek) ---

    private func schedulePeekNotification() {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "Time to Reflect"
                content.body = "Take a moment to peek into your Thought Jar."
                content.sound = .default

                var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)

                if frequency == "Weekly" {
                    // If weekly, use the selected weekday
                    dateComponents.weekday = selectedWeekday
                }

                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: "daily_reminder", content: content, trigger: trigger)

                center.add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error)")
                    }
                }

                // Close sheet on success
                DispatchQueue.main.async {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }

    private func cancelPeekNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["daily_reminder"])
        presentationMode.wrappedValue.dismiss()
    }

    // --- Logic for Section 2 (Inactivity) ---

    private func deleteInactivityNotification() {
        // 1. Remove the pending notification from the system
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["inactivity_reminder"])

        // 2. Update the AppStorage flag so it doesn't get re-scheduled automatically
        inactivityReminderEnabled = false

        // 3. Dismiss the view
        presentationMode.wrappedValue.dismiss()
    }

    private func scheduleInactivityNotification() {
        let center = UNUserNotificationCenter.current()
        let identifier = "inactivity_reminder"

        // Always remove existing to reset the timer (start fresh from now)
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = "Thought Jar"
        content.body = "What made you smile recently?"
        content.sound = .default

        // 7 days * 24 hours * 60 minutes * 60 seconds
        let interval: TimeInterval = 7 * 24 * 60 * 60
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("Error scheduling inactivity notification: \(error)")
            } else {
                print("Inactivity notification scheduled for 7 days from now (via Settings).")
            }
        }
    }
}

//#Preview {
//    NotificationSettingsView()
//}
