import Foundation

struct FeatureFlags {
    static let shared = FeatureFlags()

    private let defaults = UserDefaults.standard
    private let prefix = "feature_"

    private init() {}

    // Core Features
    var isSwipeUndoEnabled: Bool { getBool("swipe_undo", default: true) }
    var isVideoSupportEnabled: Bool { getBool("video_support", default: true) }
    var isHapticFeedbackEnabled: Bool { getBool("haptic_feedback", default: true) }
    var isFullscreenPreviewEnabled: Bool { getBool("fullscreen_preview", default: true) }

    // Experimental Features
    var isThumbnailPrefetchEnabled: Bool { getBool("thumbnail_prefetch", default: true) }
    var isSmartSortEnabled: Bool { getBool("smart_sort", default: false) }
    var isBurstGroupingEnabled: Bool { getBool("burst_grouping", default: true) }
    var isStoragePreviewEnabled: Bool { getBool("storage_preview", default: true) }
    var isBatchDeleteEnabled: Bool { getBool("batch_delete", default: true) }
    var isSessionAnalyticsEnabled: Bool { getBool("session_analytics", default: false) }

    // UI Features
    var isDarkModeOnly: Bool { getBool("dark_mode_only", default: true) }
    var isAnimatedTransitionsEnabled: Bool { getBool("animated_transitions", default: true) }
    var isPullToRefreshEnabled: Bool { getBool("pull_to_refresh", default: false) }
    var isTripFilteringEnabled: Bool { getBool("trip_filtering", default: true) }

    // Debug Features
    var isDebugLoggingEnabled: Bool { getBool("debug_logging", default: false) }
    var isPerformanceMetricsEnabled: Bool { getBool("performance_metrics", default: false) }
    var isMockDataEnabled: Bool { getBool("mock_data", default: false) }

    // Feature Toggle Management
    func setFeature(_ feature: String, enabled: Bool) {
        defaults.set(enabled, forKey: prefix + feature)
    }

    func isFeatureEnabled(_ feature: String) -> Bool {
        defaults.bool(forKey: prefix + feature)
    }

    func resetAllFeatures() {
        for key in defaults.dictionaryRepresentation().keys {
            if key.hasPrefix(prefix) {
                defaults.removeObject(forKey: key)
            }
        }
    }

    // Private helper
    private func getBool(_ key: String, default defaultValue: Bool) -> Bool {
        let fullKey = prefix + key
        if defaults.object(forKey: fullKey) == nil {
            return defaultValue
        }
        return defaults.bool(forKey: fullKey)
    }
}

// Feature flag names for easy reference
enum FeatureName: String, CaseIterable {
    case swipeUndo = "swipe_undo"
    case videoSupport = "video_support"
    case hapticFeedback = "haptic_feedback"
    case fullscreenPreview = "fullscreen_preview"
    case thumbnailPrefetch = "thumbnail_prefetch"
    case smartSort = "smart_sort"
    case burstGrouping = "burst_grouping"
    case storagePreview = "storage_preview"
    case batchDelete = "batch_delete"
    case sessionAnalytics = "session_analytics"
    case darkModeOnly = "dark_mode_only"
    case animatedTransitions = "animated_transitions"
    case pullToRefresh = "pull_to_refresh"
    case tripFiltering = "trip_filtering"
    case debugLogging = "debug_logging"
    case performanceMetrics = "performance_metrics"
    case mockData = "mock_data"
}