import Foundation

final class AppLifecycleManager {
    static let shared = AppLifecycleManager()
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }
    
    @objc private func appWillEnterForeground() {
        Logger.shared.info("App will enter foreground")
        AnalyticsService.shared.trackEvent(AnalyticsEvent(name: "app_foreground", properties: [:]))
    }
    
    @objc private func appDidEnterBackground() {
        Logger.shared.info("App did enter background")
        AnalyticsService.shared.trackEvent(AnalyticsEvent(name: "app_background", properties: [:]))
    }
    
    @objc private func appWillTerminate() {
        Logger.shared.info("App will terminate")
    }
}

import UIKit