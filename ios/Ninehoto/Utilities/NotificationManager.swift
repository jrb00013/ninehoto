import Foundation

final class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    enum NotificationType {
        case sessionComplete
        case deleteComplete
        case error(String)
    }
    
    func scheduleLocalNotification(type: NotificationType, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Logger.shared.error("Failed to schedule notification: \(error)")
            }
        }
    }
    
    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }
}

import UserNotifications