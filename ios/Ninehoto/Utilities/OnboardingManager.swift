import Foundation

struct OnboardingStep: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
}

final class OnboardingManager {
    static let shared = OnboardingManager()
    
    private let defaults = UserDefaults.standard
    private let hasCompletedKey = "onboarding_completed"
    
    private init() {}
    
    var hasCompletedOnboarding: Bool {
        defaults.bool(forKey: hasCompletedKey)
    }
    
    var onboardingSteps: [OnboardingStep] {
        [
            OnboardingStep(
                title: "Welcome to Ninehoto",
                description: "Swipe left to delete, right to keep. Simple as that!",
                imageName: "welcome"
            ),
            OnboardingStep(
                title: "Review Your Photos",
                description: "Browse through your photos and videos in a swipe interface.",
                imageName: "review"
            ),
            OnboardingStep(
                title: "Confirm Deletion",
                description: "Nothing is deleted until you confirm. Your photos are safe!",
                imageName: "confirm"
            )
        ]
    }
    
    func completeOnboarding() {
        defaults.set(true, forKey: hasCompletedKey)
    }
    
    func resetOnboarding() {
        defaults.set(false, forKey: hasCompletedKey)
    }
}