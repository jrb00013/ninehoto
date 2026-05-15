import Foundation

final class SessionManager {
    static let shared = SessionManager()
    
    private var currentSession: Session?
    
    private init() {}
    
    struct Session {
        let id: UUID
        let startTime: Date
        var endTime: Date?
        var actions: [SessionAction]
    }
    
    struct SessionAction {
        let type: ActionType
        let timestamp: Date
        let details: [String: Any]
        
        enum ActionType {
            case swipeLeft
            case swipeRight
            case undo
            case delete
            case cancel
        }
    }
    
    func startSession() -> Session {
        let session = Session(
            id: UUID(),
            startTime: Date(),
            endTime: nil,
            actions: []
        )
        currentSession = session
        return session
    }
    
    func endSession() -> Session? {
        guard var session = currentSession else { return nil }
        session.endTime = Date()
        currentSession = nil
        return session
    }
    
    func recordAction(_ type: SessionAction.ActionType, details: [String: Any] = [:]) {
        guard currentSession != nil else { return }
        
        let action = SessionAction(type: type, timestamp: Date(), details: details)
        currentSession?.actions.append(action)
    }
    
    var isSessionActive: Bool {
        currentSession != nil
    }
}