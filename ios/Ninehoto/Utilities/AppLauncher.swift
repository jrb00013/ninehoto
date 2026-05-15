import Foundation

final class AppLauncher {
    static let shared = AppLauncher()
    
    private init() {}
    
    func launch() async {
        Logger.shared.info("App launching...")
        
        // Initialize services
        _ = Logger.shared
        _ = PreferencesManager.shared
        _ = AnalyticsService.shared
        _ = FeatureFlags.shared
        
        // Initialize managers
        _ = SystemMonitor.shared
        _ = KeyboardManager.shared
        _ = AppLifecycleManager.shared
        
        // Run migrations
        DataMigrationManager.shared.migrateIfNeeded()
        
        Logger.shared.info("App launch complete")
    }
    
    func handleDeepLink(_ url: URL) -> Bool {
        DeepLinkHandler.shared.handle(url)
    }
    
    func handleShortcut(_ item: UIApplicationShortcutItem) {
        ShortcutManager.shared.handleShortcut(item)
    }
}