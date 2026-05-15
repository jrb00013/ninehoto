import Foundation

final class AppProfiler {
    static let shared = AppProfiler()
    
    private var sections: [String: TimeInterval] = [:]
    private var startTimes: [String: Date] = [:]
    
    private init() {}
    
    func startProfiling(_ section: String) {
        startTimes[section] = Date()
    }
    
    func endProfiling(_ section: String) {
        guard let start = startTimes[section] else { return }
        
        let duration = Date().timeIntervalSince(start)
        sections[section] = duration
        startTimes.removeValue(forKey: section)
    }
    
    func getSectionDuration(_ section: String) -> TimeInterval? {
        sections[section]
    }
    
    func getAllDurations() -> [String: TimeInterval] {
        sections
    }
    
    func clear() {
        sections.removeAll()
        startTimes.removeAll()
    }
}