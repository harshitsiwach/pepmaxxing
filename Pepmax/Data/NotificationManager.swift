import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    @Published var pendingReminders: [ReminderSchedule] = []
    
    init() {
        loadReminders()
        checkAuthorization()
    }
    
    // MARK: - Authorization
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
        }
    }
    
    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Schedule Reminders
    
    func scheduleReminder(_ reminder: ReminderSchedule) {
        guard isAuthorized else {
            requestPermission()
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "💉 Pepmax Reminder"
        content.body = "Time for your \(reminder.peptideName) dose (\(reminder.dosage))"
        content.sound = .default
        content.badge = 1
        
        var dateComponents = DateComponents()
        dateComponents.hour = reminder.hour
        dateComponents.minute = reminder.minute
        
        // Set specific days if configured
        if !reminder.days.isEmpty {
            for day in reminder.days {
                var dayComponents = dateComponents
                dayComponents.weekday = day // 1 = Sunday, 7 = Saturday
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dayComponents, repeats: true)
                let request = UNNotificationRequest(
                    identifier: "\(reminder.id.uuidString)_\(day)",
                    content: content,
                    trigger: trigger
                )
                UNUserNotificationCenter.current().add(request)
            }
        } else {
            // Daily reminder
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: reminder.id.uuidString,
                content: content,
                trigger: trigger
            )
            UNUserNotificationCenter.current().add(request)
        }
        
        pendingReminders.append(reminder)
        saveReminders()
        Haptics.notification(.success)
    }
    
    func removeReminder(_ reminder: ReminderSchedule) {
        // Remove from notification center
        if !reminder.days.isEmpty {
            let ids = reminder.days.map { "\(reminder.id.uuidString)_\($0)" }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString])
        }
        
        pendingReminders.removeAll { $0.id == reminder.id }
        saveReminders()
    }
    
    func toggleReminder(_ reminder: ReminderSchedule) {
        if let idx = pendingReminders.firstIndex(where: { $0.id == reminder.id }) {
            var updated = pendingReminders[idx]
            updated.isEnabled.toggle()
            
            if updated.isEnabled {
                scheduleReminder(updated)
            } else {
                removeReminder(updated)
                pendingReminders.insert(updated, at: idx)
            }
            
            pendingReminders[idx] = updated
            saveReminders()
        }
    }
    
    // MARK: - Persistence
    
    private func saveReminders() {
        if let data = try? JSONEncoder().encode(pendingReminders) {
            UserDefaults.standard.set(data, forKey: "scheduled_reminders")
        }
    }
    
    private func loadReminders() {
        guard let data = UserDefaults.standard.data(forKey: "scheduled_reminders"),
              let reminders = try? JSONDecoder().decode([ReminderSchedule].self, from: data) else { return }
        pendingReminders = reminders
    }
}

// MARK: - Reminder Model

struct ReminderSchedule: Identifiable, Codable {
    let id: UUID
    var peptideName: String
    var dosage: String
    var hour: Int
    var minute: Int
    var days: [Int] // Empty = daily, otherwise weekday numbers (1-7)
    var isEnabled: Bool
    
    init(id: UUID = UUID(), peptideName: String, dosage: String, hour: Int, minute: Int, days: [Int] = [], isEnabled: Bool = true) {
        self.id = id
        self.peptideName = peptideName
        self.dosage = dosage
        self.hour = hour
        self.minute = minute
        self.days = days
        self.isEnabled = isEnabled
    }
    
    var timeString: String {
        let h = hour % 12 == 0 ? 12 : hour % 12
        let period = hour >= 12 ? "PM" : "AM"
        return String(format: "%d:%02d %@", h, minute, period)
    }
    
    var daysString: String {
        if days.isEmpty { return "Every day" }
        let dayNames = ["", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return days.map { dayNames[$0] }.joined(separator: ", ")
    }
}
