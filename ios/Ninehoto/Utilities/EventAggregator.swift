import Foundation

struct AppEvent {
    let id: UUID
    let name: String
    let timestamp: Date
    let properties: [String: Any]
}

final class EventAggregator {
    static let shared = EventAggregator()
    
    private var handlers: [String: [(AppEvent) -> Void]] = [:]
    private var eventHistory: [AppEvent] = []
    
    private init() {}
    
    func publish(_ event: AppEvent) {
        eventHistory.append(event)
        
        if let handlers = handlers[event.name] {
            for handler in handlers {
                handler(event)
            }
        }
    }
    
    func subscribe(to eventName: String, handler: @escaping (AppEvent) -> Void) {
        if handlers[eventName] == nil {
            handlers[eventName] = []
        }
        handlers[eventName]?.append(handler)
    }
    
    func unsubscribe(from eventName: String) {
        handlers.removeValue(forKey: eventName)
    }
    
    func getHistory(for eventName: String? = nil) -> [AppEvent] {
        if let name = eventName {
            return eventHistory.filter { $0.name == name }
        }
        return eventHistory
    }
    
    func clearHistory() {
        eventHistory.removeAll()
    }
}