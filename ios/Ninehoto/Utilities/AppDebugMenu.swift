import Foundation

final class AppDebugMenu {
    static let shared = AppDebugMenu()
    
    private init() {}
    
    var menuItems: [DebugMenuItem] {
        [
            DebugMenuItem(title: "Clear Cache", action: { ImageCacheManager.shared.clearAllCaches() }),
            DebugMenuItem(title: "Clear Logs", action: { AppLogger.shared.clearLogs() }),
            DebugMenuItem(title: "Reset Statistics", action: { PreferencesManager.shared.resetStatistics() }),
            DebugMenuItem(title: "Toggle Feature Flags", action: { FeatureFlags.shared.resetAllFeatures() }),
            DebugMenuItem(title: "Show Performance Report", action: { PerformanceMonitor.shared.printReport() })
        ]
    }
}

struct DebugMenuItem {
    let title: String
    let action: () -> Void
}