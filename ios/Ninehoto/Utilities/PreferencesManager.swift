import Foundation

final class PreferencesManager {
    static let shared = PreferencesManager()

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let lastSessionDate = "lastSessionDate"
        static let swipeCount = "swipeCount"
        static let deleteCount = "deleteCount"
        static let keepCount = "keepCount"
        static let hapticFeedbackEnabled = "hapticFeedbackEnabled"
        static let preferredSortOrder = "preferredSortOrder"
        static let thumbnailQuality = "thumbnailQuality"
    }

    private init() {}

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: Keys.hasCompletedOnboarding) }
        set { defaults.set(newValue, forKey: Keys.hasCompletedOnboarding) }
    }

    var lastSessionDate: Date? {
        get { defaults.object(forKey: Keys.lastSessionDate) as? Date }
        set { defaults.set(newValue, forKey: Keys.lastSessionDate) }
    }

    var swipeCount: Int {
        get { defaults.integer(forKey: Keys.swipeCount) }
        set { defaults.set(newValue, forKey: Keys.swipeCount) }
    }

    var deleteCount: Int {
        get { defaults.integer(forKey: Keys.deleteCount) }
        set { defaults.set(newValue, forKey: Keys.deleteCount) }
    }

    var keepCount: Int {
        get { defaults.integer(forKey: Keys.keepCount) }
        set { defaults.set(newValue, forKey: Keys.keepCount) }
    }

    var hapticFeedbackEnabled: Bool {
        get {
            if defaults.object(forKey: Keys.hapticFeedbackEnabled) == nil {
                return true
            }
            return defaults.bool(forKey: Keys.hapticFeedbackEnabled)
        }
        set { defaults.set(newValue, forKey: Keys.hapticFeedbackEnabled) }
    }

    enum SortOrder: Int, Codable, CaseIterable {
        case dateDescending = 0
        case dateAscending = 1
        case creationDateDescending = 2

        var displayName: String {
            switch self {
            case .dateDescending: return "Newest First"
            case .dateAscending: return "Oldest First"
            case .creationDateDescending: return "Recently Added"
            }
        }
    }

    var preferredSortOrder: SortOrder {
        get {
            let rawValue = defaults.integer(forKey: Keys.preferredSortOrder)
            return SortOrder(rawValue: rawValue) ?? .dateDescending
        }
        set { defaults.set(newValue.rawValue, forKey: Keys.preferredSortOrder) }
    }

    enum ThumbnailQuality: Int, Codable, CaseIterable {
        case low = 0
        case medium = 1
        case high = 2

        var displayName: String {
            switch self {
            case .low: return "Low (Fast)"
            case .medium: return "Medium"
            case .high: return "High (Slow)"
            }
        }
    }

    var thumbnailQuality: ThumbnailQuality {
        get {
            let rawValue = defaults.integer(forKey: Keys.thumbnailQuality)
            return ThumbnailQuality(rawValue: rawValue) ?? .medium
        }
        set { defaults.set(newValue.rawValue, forKey: Keys.thumbnailQuality) }
    }

    func incrementSwipeCount() {
        swipeCount += 1
    }

    func incrementDeleteCount() {
        deleteCount += 1
    }

    func incrementKeepCount() {
        keepCount += 1
    }

    func resetStatistics() {
        swipeCount = 0
        deleteCount = 0
        keepCount = 0
    }

    func clearAll() {
        let domain = Bundle.main.bundleIdentifier ?? "com.ninehoto.app"
        defaults.removePersistentDomain(forName: domain)
    }
}