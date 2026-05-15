import Foundation

final class ReviewManager {
    static let shared = ReviewManager()
    
    private init() {}
    
    func requestReview() {
        if #available(iOS 14.0, *) {
            SKStoreReviewController.requestReview()
        }
    }
    
    func shouldShowReviewPrompt() -> Bool {
        let lastPromptDate = UserDefaults.standard.object(forKey: "last_review_prompt_date") as? Date
        let sessionCount = UserDefaults.standard.integer(forKey: "session_count")
        
        guard sessionCount >= 5 else { return false }
        
        if let lastDate = lastPromptDate {
            let daysSinceLastPrompt = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
            return daysSinceLastPrompt >= 30
        }
        
        return true
    }
    
    func recordSession() {
        let count = UserDefaults.standard.integer(forKey: "session_count")
        UserDefaults.standard.set(count + 1, forKey: "session_count")
    }
    
    func promptForReview() {
        guard shouldShowReviewPrompt() else { return }
        
        UserDefaults.standard.set(Date(), forKey: "last_review_prompt_date")
        requestReview()
    }
}

import StoreKit