import Foundation

final class AppConfigManager {
    static let shared = AppConfigManager()
    
    private var configs: [String: Any] = [:]
    
    private init() {
        loadDefaultConfig()
    }
    
    private func loadDefaultConfig() {
        configs = [
            "app_name": "ninehoto",
            "version": Bundle.main.appVersion,
            "build": Bundle.main.buildNumber,
            "min_ios_version": "16.0",
            "max_cache_size_mb": 100,
            "enable_logging": true,
            "enable_analytics": false,
            "feature_flags": [
                "swipe_undo": true,
                "video_support": true,
                "haptic_feedback": true,
                "fullscreen_preview": true
            ]
        ]
    }
    
    func get<T>(forKey key: String) -> T? {
        configs[key] as? T
    }
    
    func set(_ value: Any, forKey key: String) {
        configs[key] = value
    }
    
    func reload() {
        loadDefaultConfig()
    }
}