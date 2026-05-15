import Foundation

final class HapticsManager {
    static let shared = HapticsManager()
    
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let impactGenerator = UIImpactFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    private init() {
        prepare()
    }
    
    private func prepare() {
        notificationGenerator.prepare()
        impactGenerator.prepare()
        selectionGenerator.prepare()
    }
    
    func playSuccess() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    func playWarning() {
        notificationGenerator.notificationOccurred(.warning)
    }
    
    func playError() {
        notificationGenerator.notificationOccurred(.error)
    }
    
    func playImpact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        impactGenerator.impactOccurred(style: style)
    }
    
    func playSelection() {
        selectionGenerator.selectionChanged()
    }
}

import UIKit