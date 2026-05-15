import Foundation

final class AnalyticsService {
    static let shared = AnalyticsService()
    
    private let userDefaults = UserDefaults.standard
    private let eventKey = "analytics_events"
    
    private init() {}
    
    func trackEvent(_ event: AnalyticsEvent) {
        guard FeatureFlags.shared.isSessionAnalyticsEnabled else { return }
        
        var events = loadEvents()
        events.append(event)
        
        saveEvents(events)
        
        Logger.shared.info("Analytics: \(event.name) - \(event.properties)")
    }
    
    func trackSessionStart() {
        trackEvent(AnalyticsEvent(
            name: "session_start",
            properties: ["timestamp": Date().timeIntervalSince1970]
        ))
    }
    
    func trackSessionEnd(swipeCount: Int, deleteCount: Int, keepCount: Int) {
        trackEvent(AnalyticsEvent(
            name: "session_end",
            properties: [
                "swipe_count": swipeCount,
                "delete_count": deleteCount,
                "keep_count": keepCount,
                "duration": Date().timeIntervalSince1970
            ]
        ))
    }
    
    func trackSwipe(direction: SwipeDirection, index: Int) {
        trackEvent(AnalyticsEvent(
            name: "swipe",
            properties: [
                "direction": direction.rawValue,
                "index": index
            ]
        ))
    }
    
    func trackUndo() {
        trackEvent(AnalyticsEvent(name: "undo", properties: [:]))
    }
    
    func trackDeleteConfirmation(count: Int) {
        trackEvent(AnalyticsEvent(
            name: "delete_confirmation",
            properties: ["count": count]
        ))
    }
    
    func trackDeleteSuccess(count: Int) {
        trackEvent(AnalyticsEvent(
            name: "delete_success",
            properties: ["count": count]
        ))
    }
    
    func trackPermissionDenied() {
        trackEvent(AnalyticsEvent(name: "permission_denied", properties: [:]))
    }
    
    func trackError(error: AppError) {
        trackEvent(AnalyticsEvent(
            name: "error",
            properties: ["type": error.errorType.rawValue]
        ))
    }
    
    func getEvents() -> [AnalyticsEvent] {
        loadEvents()
    }
    
    func clearEvents() {
        userDefaults.removeObject(forKey: eventKey)
    }
    
    private func loadEvents() -> [AnalyticsEvent] {
        guard let data = userDefaults.data(forKey: eventKey),
              let events = try? JSONDecoder().decode([AnalyticsEvent].self, from: data) else {
            return []
        }
        return events
    }
    
    private func saveEvents(_ events: [AnalyticsEvent]) {
        if let data = try? JSONEncoder().encode(events) {
            userDefaults.set(data, forKey: eventKey)
        }
    }
    
    func getSessionCount() -> Int {
        loadEvents().filter { $0.name == "session_start" }.count
    }
    
    func getTotalSwipes() -> Int {
        loadEvents()
            .filter { $0.name == "swipe" }
            .count
    }
}

struct AnalyticsEvent: Codable, Identifiable {
    let id: UUID
    let name: String
    let properties: [String: Any]
    let timestamp: Date
    
    init(name: String, properties: [String: Any]) {
        self.id = UUID()
        self.name = name
        self.properties = properties
        self.timestamp = Date()
    }
}

extension AnalyticsEvent {
    var description: String {
        "\(name) at \(timestamp)"
    }
}