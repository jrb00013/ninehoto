import UIKit

final class AccessibilityManager {
    static let shared = AccessibilityManager()

    private init() {}

    var isVoiceOverEnabled: Bool {
        UIAccessibility.isVoiceOverRunning
    }

    var isReduceMotionEnabled: Bool {
        UIAccessibility.isReduceMotionEnabled
    }

    var isReduceTransparencyEnabled: Bool {
        UIAccessibility.isReduceTransparencyEnabled
    }

    var isBoldTextEnabled: Bool {
        UIAccessibility.isBoldTextEnabled
    }

    var preferredContentSizeCategory: UIUserInterfaceSizeCategory {
        UIAccessibility.preferredContentSizeCategory
    }

    func announce(_ message: String, priority: UIAccessibilityPriority = .medium) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }

    func postLayoutChangedNotification(_ element: Any? = nil) {
        UIAccessibility.post(notification: .layoutChanged, argument: element)
    }

    func postScreenChangedNotification(_ element: Any? = nil) {
        UIAccessibility.post(notification: .screenChanged, argument: element)
    }

    func createAttributedString(
        _ text: String,
        fontSize: CGFloat,
        weight: UIFont.Weight = .regular
    ) -> NSAttributedString {
        let baseFont = UIFont.preferredFont(forTextStyle: .body)
        let metrics = UIFontMetrics(forTextStyle: .body)
        let font = metrics.scaledFont(for: UIFont.systemFont(ofSize: fontSize, weight: weight))

        return NSAttributedString(
            string: text,
            attributes: [.font: font]
        )
    }

    func accessibilityLabel(for mediaItem: MediaItem) -> String {
        var components: [String] = []

        switch mediaItem.mediaType {
        case .photo:
            components.append("Photo")
        case .video:
            components.append("Video")
        case .unknown:
            components.append("Media")
        }

        if let date = mediaItem.creationDate {
            components.append(date.relativeFormatted)
        }

        if mediaItem.isVideo, let duration = mediaItem.formattedDuration {
            components.append("Duration: \(duration)")
        }

        return components.joined(separator: ", ")
    }

    func shouldUseLargerTouchTargets() -> Bool {
        preferredContentSizeCategory >= .extraLarge
    }

    func announceSwipeAction(direction: SwipeDirection) {
        let message = direction == .left
            ? LocalizationManager.shared.translate(.swipeLeftToDelete)
            : LocalizationManager.shared.translate(.swipeRightToKeep)
        announce(message)
    }

    func announceProgress(current: Int, total: Int) {
        let message = LocalizationManager.shared.translate(.progressAccessibility, args: current, total)
        announce(message)
    }

    func configureButtonAccessibility(
        for button: UIButton,
        label: String,
        hint: String? = nil
    ) {
        button.accessibilityLabel = label
        button.accessibilityHint = hint
    }
}