import Foundation

struct SessionStatistics: Codable, Equatable {
    var swipeCount: Int
    var deleteCount: Int
    var keepCount: Int
    var sessionDate: Date
    var durationSeconds: TimeInterval
    var averageSwipesPerMinute: Double
    var spaceSavedBytes: Int64

    static var empty: SessionStatistics {
        SessionStatistics(
            swipeCount: 0,
            deleteCount: 0,
            keepCount: 0,
            sessionDate: Date(),
            durationSeconds: 0,
            averageSwipesPerMinute: 0,
            spaceSavedBytes: 0
        )
    }

    var deleteRate: Double {
        guard swipeCount > 0 else { return 0 }
        return Double(deleteCount) / Double(swipeCount) * 100
    }

    var keepRate: Double {
        guard swipeCount > 0 else { return 0 }
        return Double(keepCount) / Double(swipeCount) * 100
    }

    var formattedDuration: String {
        let minutes = Int(durationSeconds) / 60
        let seconds = Int(durationSeconds) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }
        return "\(seconds)s"
    }
}

final class StatisticsTracker {
    static let shared = StatisticsTracker()

    private let userDefaults = UserDefaults.standard
    private let keyPrefix = "statistics_"

    private init() {}

    func saveSession(_ statistics: SessionStatistics) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let key = keyPrefix + dateFormatter.string(from: statistics.sessionDate)

        if let data = try? JSONEncoder().encode(statistics) {
            userDefaults.set(data, forKey: key)
        }

        PreferencesManager.shared.lastSessionDate = statistics.sessionDate
    }

    func getAllSessions() -> [SessionStatistics] {
        var sessions: [SessionStatistics] = []

        for key in userDefaults.dictionaryRepresentation().keys {
            guard key.hasPrefix(keyPrefix),
                  let data = userDefaults.data(forKey: key),
                  let statistics = try? JSONDecoder().decode(SessionStatistics.self, from: data) else {
                continue
            }
            sessions.append(statistics)
        }

        return sessions.sorted { $0.sessionDate > $1.sessionDate }
    }

    func getTotalStatistics() -> SessionStatistics {
        let sessions = getAllSessions()

        let totalSwipes = sessions.reduce(0) { $0 + $1.swipeCount }
        let totalDeletes = sessions.reduce(0) { $0 + $1.deleteCount }
        let totalKeeps = sessions.reduce(0) { $0 + $1.keepCount }
        let totalDuration = sessions.reduce(0) { $0 + $1.durationSeconds }
        let totalSpace = sessions.reduce(0 as Int64) { $0 + $1.spaceSavedBytes }

        return SessionStatistics(
            swipeCount: totalSwipes,
            deleteCount: totalDeletes,
            keepCount: totalKeeps,
            sessionDate: Date(),
            durationSeconds: totalDuration,
            averageSwipesPerMinute: totalSwipes > 0 ? (totalSwipes / (totalDuration / 60)) : 0,
            spaceSavedBytes: totalSpace
        )
    }

    func clearAll() {
        for key in userDefaults.dictionaryRepresentation().keys {
            if key.hasPrefix(keyPrefix) {
                userDefaults.removeObject(forKey: key)
            }
        }
    }
}