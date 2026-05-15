import Foundation

final class DynamicTypeManager {
    static let shared = DynamicTypeManager()
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contentSizeChanged),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
    }
    
    @objc private func contentSizeChanged() {
        NotificationCenter.default.post(name: .dynamicTypeChanged, object: nil)
    }
    
    var currentCategory: UIContentSizeCategory {
        UIApplication.shared.preferredContentSizeCategory
    }
    
    var isAccessibility: Bool {
        currentCategory >= .accessibilityMedium
    }
    
    var scaleFactor: CGFloat {
        switch currentCategory {
        case .extraSmall: return 0.8
        case .small: return 0.9
        case .medium: return 1.0
        case .large: return 1.1
        case .extraLarge: return 1.2
        case .extraExtraLarge: return 1.3
        case .extraExtraExtraLarge: return 1.4
        default: return 1.5
        }
    }
}

extension Notification.Name {
    static let dynamicTypeChanged = Notification.Name("dynamicTypeChanged")
}

import UIKit