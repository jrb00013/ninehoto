import Foundation
import SwiftUI

extension Color {
    static let primaryBackground = Color(uiColor: UIColor.systemBackground)
    static let secondaryBackground = Color(uiColor: UIColor.secondarySystemBackground)
    static let tertiaryBackground = Color(uiColor: UIColor.tertiarySystemBackground)
    static let cardBackground = Color(uiColor: UIColor.secondarySystemBackground)
    static let destructiveRed = Color.red
    static let keepGreen = Color.green
    static let swipeIndicatorYellow = Color.yellow
}

extension View {
    func cardStyle() -> some View {
        self
            .background(Color.cardBackground)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    func hapticOnTap(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { HapticManager.shared.impact(style) }
        )
    }
}

extension Date {
    var relativeFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    var shortFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

extension Int {
    var formattedWithSeparator: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

extension Result {
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }

    var isFailure: Bool {
        !isSuccess
    }
}