import Foundation

final class ErrorRecoveryManager {
    static let shared = ErrorRecoveryManager()
    
    private init() {}
    
    enum RecoveryStrategy {
        case retry
        case fallback
        case skip
        case abort
    }
    
    func handleError(_ error: Error, strategy: RecoveryStrategy, action: () -> Void) {
        switch strategy {
        case .retry:
            performRetry(action: action)
        case .fallback:
            performFallback(action: action)
        case .skip:
            Logger.shared.warning("Skipping failed operation")
        case .abort:
            Logger.shared.error("Aborting operation due to error")
        }
    }
    
    private func performRetry(action: () -> Void, maxAttempts: Int = 3) {
        var attempts = 0
        
        while attempts < maxAttempts {
            do {
                action()
                break
            } catch {
                attempts += 1
                if attempts >= maxAttempts {
                    Logger.shared.error("Max retry attempts reached")
                } else {
                    Logger.shared.warning("Retry attempt \(attempts) failed, retrying...")
                }
            }
        }
    }
    
    private func performFallback(action: () -> Void) {
        do {
            action()
        } catch {
            Logger.shared.warning("Fallback action failed, using default behavior")
        }
    }
}