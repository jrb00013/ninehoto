import Foundation

final class ColorSchemeManager {
    static let shared = ColorSchemeManager()
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(colorSchemeChanged),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func colorSchemeChanged() {
        updateColorScheme()
    }
    
    private func updateColorScheme() {
        let style = UITraitCollection.current.userInterfaceStyle
        UserDefaults.standard.set(style.rawValue, forKey: "color_scheme")
    }
    
    var currentScheme: UIUserInterfaceStyle {
        let rawValue = UserDefaults.standard.integer(forKey: "color_scheme")
        return UIUserInterfaceStyle(rawValue: rawValue) ?? .dark
    }
    
    var isDarkMode: Bool {
        currentScheme == .dark
    }
    
    func setDarkMode(_ enabled: Bool) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            window.overrideUserInterfaceStyle = enabled ? .dark : .light
        }
    }
}

import UIKit