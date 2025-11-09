//
//  NotificationManager.swift
//  Thought Jar
//
//  Created by Suhas Vasu on 11/8/25.
//

import Foundation
import UserNotifications

// Enum to store frequency (no change here)
enum ReminderFrequency: String, CaseIterable, Identifiable {
    case daily
    case weekly
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .daily:
            return "Daily"
        case .weekly:
            return "Weekly"
        }
    }
}

class NotificationManager {
    
    static let shared = NotificationManager()
    
    /// 1. Request user authorization (no change here)
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    /// 2. Schedule a recurring notification (MODIFIED)
    func scheduleNotification(frequency: ReminderFrequency, time: Date, weekday: Int) { // <-- Added 'weekday' parameter
        // First, cancel all previous notifications to avoid duplicates
        cancelAllNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "Thought Jar"
        content.body = "Lets take a trip down memory lane."
        content.sound = .default
        
        // Create date components from the user's selected time
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
        
        if frequency == .weekly {
            // --- MODIFIED ---
            // Use the day of week selected by the user
            dateComponents.weekday = weekday
            // --- END OF MODIFICATION ---
        }
        
        // Create a trigger that repeats based on the date components
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                
                // Use DateFormatter for compatibility
                let formatter = DateFormatter()
                formatter.dateStyle = .none
                formatter.timeStyle = .short
                
                // --- MODIFIED: Updated print statement for weekly ---
                if frequency == .weekly {
                    let weekdaySymbol = Calendar.current.weekdaySymbols[weekday - 1] // Get day name
                    print("Notification scheduled successfully for \(frequency.displayName) on \(weekdaySymbol) at \(formatter.string(from: time))")
                } else {
                    print("Notification scheduled successfully for \(frequency.displayName) at \(formatter.string(from: time))")
                }
                // --- END OF MODIFICATION ---
            }
        }
    }
    
    /// 3. Cancel all pending notifications (no change here)
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("All pending notifications cancelled.")
    }
}
