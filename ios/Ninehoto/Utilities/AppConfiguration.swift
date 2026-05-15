import Foundation

struct AppConfiguration {
    static let shared = AppConfiguration()
    
    private let config: [String: Any]
    
    private init() {
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
            config = dict
        } else {
            config = [:]
        }
    }
    
    var apiBaseURL: String {
        config["api_base_url"] as? String ?? "https://api.ninehoto.com"
    }
    
    var maxSessionItems: Int {
        config["max_session_items"] as? Int ?? 200
    }
    
    var thumbnailSize: Int {
        config["thumbnail_size"] as? Int ?? 200
    }
    
    var enableAnalytics: Bool {
        config["enable_analytics"] as? Bool ?? true
    }
    
    var enableDebugLogs: Bool {
        config["enable_debug_logs"] as? Bool ?? false
    }
    
    var enableAnimations: Bool {
        config["enable_animations"] as? Bool ?? true
    }
    
    var hapticFeedbackEnabled: Bool {
        config["haptic_feedback_enabled"] as? Bool ?? true
    }
    
    var autoDeleteEnabled: Bool {
        config["auto_delete_enabled"] as? Bool ?? false
    }
}

enum ConfigKey: String {
    case apiBaseURL = "api_base_url"
    case maxSessionItems = "max_session_items"
    case thumbnailSize = "thumbnail_size"
    case enableAnalytics = "enable_analytics"
    case enableDebugLogs = "enable_debug_logs"
    case enableAnimations = "enable_animations"
    case hapticFeedbackEnabled = "haptic_feedback_enabled"
    case autoDeleteEnabled = "auto_delete_enabled"
}

extension AppConfiguration {
    func value<T>(for key: ConfigKey) -> T? {
        config[key.rawValue] as? T
    }
    
    func setValue<T>(_ value: T, for key: ConfigKey) {
        var mutableConfig = config
        mutableConfig[key.rawValue] = value
    }
}