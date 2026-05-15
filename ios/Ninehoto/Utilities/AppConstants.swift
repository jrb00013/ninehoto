import Foundation

enum AppConstants {
    static let sessionLimit = 200
    static let thumbnailSize = CGSize(width: 200, height: 200)
    static let prefetchCount = 5
    static let maxUndoHistory = 1000
    static let animationDuration: Double = 0.3
    static let swipeThreshold: CGFloat = 100
    
    enum Cache {
        static let memoryLimit = 50 * 1024 * 1024
        static let diskLimit = 100 * 1024 * 1024
        static let thumbnailCacheCount = 100
    }
    
    enum API {
        static let baseURL = "https://api.ninehoto.com"
        static let timeout: TimeInterval = 30
        static let retryCount = 3
    }
    
    enum Storage {
        static let preferencesKey = "ninehoto_prefs"
        static let analyticsKey = "analytics_events"
    }
}