import UIKit

final class HapticManager {
    static let shared = HapticManager()

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()

    private init() {
        prepareGenerators()
    }

    private func prepareGenerators() {
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        selectionFeedback.prepare()
        notificationFeedback.prepare()
    }

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard PreferencesManager.shared.hapticFeedbackEnabled else { return }

        switch style {
        case .light:
            lightImpact.impactOccurred()
        case .medium:
            mediumImpact.impactOccurred()
        case .heavy:
            heavyImpact.impactOccurred()
        case .soft:
            lightImpact.impactOccurred(intensity: 0.5)
        case .rigid:
            heavyImpact.impactOccurred(intensity: 0.8)
        @unknown default:
            mediumImpact.impactOccurred()
        }
    }

    func selection() {
        guard PreferencesManager.shared.hapticFeedbackEnabled else { return }
        selectionFeedback.selectionChanged()
    }

    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard PreferencesManager.shared.hapticFeedbackEnabled else { return }
        notificationFeedback.notificationOccurred(type)
    }

    func swipeLeft() {
        impact(.medium)
    }

    func swipeRight() {
        impact(.light)
    }

    func success() {
        notification(.success)
    }

    func warning() {
        notification(.warning)
    }

    func error() {
        notification(.error)
    }
}