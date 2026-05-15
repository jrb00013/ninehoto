import Foundation

final class ShortcutManager {
    static let shared = ShortcutManager()
    
    private init() {}
    
    enum ShortcutItem: String {
        case startSession = "start_session"
        case settings = "settings"
        case statistics = "statistics"
    }
    
    func handleShortcut(_ shortcutItem: UIApplicationShortcutItem) {
        guard let type = ShortcutItem(rawValue: shortcutItem.type) else { return }
        
        switch type {
        case .startSession:
            NotificationCenter.default.post(name: .shortcutStartSession, object: nil)
        case .settings:
            NotificationCenter.default.post(name: .shortcutSettings, object: nil)
        case .statistics:
            NotificationCenter.default.post(name: .shortcutStatistics, object: nil)
        }
    }
    
    static func createShortcutItems() -> [UIApplicationShortcutItem] {
        [
            UIApplicationShortcutItem(type: ShortcutItem.startSession.rawValue, localizedTitle: "Start Session", localizedSubtitle: nil, icon: nil, userInfo: nil),
            UIApplicationShortcutItem(type: ShortcutItem.statistics.rawValue, localizedTitle: "Statistics", localizedSubtitle: nil, icon: nil, userInfo: nil)
        ]
    }
}

extension Notification.Name {
    static let shortcutStartSession = Notification.Name("shortcutStartSession")
    static let shortcutSettings = Notification.Name("shortcutSettings")
    static let shortcutStatistics = Notification.Name("shortcutStatistics")
}

import UIKit