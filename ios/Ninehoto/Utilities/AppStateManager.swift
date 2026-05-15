import Foundation

enum AppState: Equatable {
    case initializing
    case mainMenu
    case loading
    case swiping(progress: Double)
    case finishConfirmation
    case deleting(progress: Double)
    case result(message: String)
    case error(AppError)
    
    static func == (lhs: AppState, rhs: AppState) -> Bool {
        switch (lhs, rhs) {
        case (.initializing, .initializing): return true
        case (.mainMenu, .mainMenu): return true
        case (.loading, .loading): return true
        case (.swiping(let p1), .swiping(let p2)): return p1 == p2
        case (.finishConfirmation, .finishConfirmation): return true
        case (.deleting(let p1), .deleting(let p2)): return p1 == p2
        case (.result(let m1), .result(let m2)): return m1 == m2
        case (.error(let e1), .error(let e2)): return e1 == e2
        default: return false
        }
    }
}

final class AppStateManager: ObservableObject {
    static let shared = AppStateManager()
    
    @Published var state: AppState = .initializing
    @Published var previousState: AppState?
    
    private let logger = Logger.shared
    
    private init() {
        logger.info("AppStateManager initialized")
    }
    
    func transition(to newState: AppState) {
        previousState = state
        state = newState
        logger.info("State transition: \(String(describing: previousState)) -> \(String(describing: state))")
    }
    
    func goToMainMenu() {
        transition(to: .mainMenu)
    }
    
    func startLoading() {
        transition(to: .loading)
    }
    
    func startSwiping(mediaCount: Int) {
        transition(to: .swiping(progress: 0))
    }
    
    func updateSwipeProgress(_ progress: Double) {
        if case .swiping = state {
            transition(to: .swiping(progress: progress))
        }
    }
    
    func showFinishConfirmation() {
        transition(to: .finishConfirmation)
    }
    
    func startDeleting(itemCount: Int) {
        transition(to: .deleting(progress: 0))
    }
    
    func updateDeleteProgress(_ progress: Double) {
        if case .deleting = state {
            transition(to: .deleting(progress: progress))
        }
    }
    
    func showResult(message: String) {
        transition(to: .result(message: message))
    }
    
    func showError(_ error: AppError) {
        transition(to: .error(error))
        logger.error("App error: \(error.localizedDescription)")
    }
    
    var canNavigateBack: Bool {
        switch state {
        case .initializing, .mainMenu, .loading:
            return false
        default:
            return true
        }
    }
}