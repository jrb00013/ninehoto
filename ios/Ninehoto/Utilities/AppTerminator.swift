import Foundation

final class AppTerminator {
    static let shared = AppTerminator()
    
    private init() {}
    
    func terminate() {
        Logger.shared.info("App terminating...")
        
        // Save state
        CacheManager.shared.clearAll()
        
        // Cancel operations
        NetworkMonitor.shared.stopMonitoring()
        
        // Log session
        AnalyticsService.shared.trackEvent(AnalyticsEvent(name: "app_terminated", properties: [:]))
        
        // Clean up
        AppLifecycleManager.shared.stopUpdatingLocation()
    }
    
    func prepareForTermination() {
        // Save any pending data
        UserDefaults.standard.synchronize()
    }
}