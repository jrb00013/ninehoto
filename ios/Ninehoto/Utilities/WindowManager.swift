import UIKit

final class WindowManager {
    static let shared = WindowManager()
    
    private(set) var mainWindow: UIWindow?
    private(set) var currentWindowScene: UIWindowScene?
    
    private init() {}
    
    func configure(with windowScene: UIWindowScene) {
        currentWindowScene = windowScene
        mainWindow = windowScene.windows.first
    }
    
    var screenBounds: CGRect {
        guard let window = mainWindow else { return .zero }
        return window.bounds
    }
    
    var safeAreaInsets: UIEdgeInsets {
        guard let window = mainWindow else { return .zero }
        return window.safeAreaInsets
    }
    
    var isLandscape: Bool {
        screenBounds.width > screenBounds.height
    }
    
    var isPortrait: Bool {
        screenBounds.height > screenBounds.width
    }
    
    var screenScale: CGFloat {
        mainWindow?.screen.scale ?? 1.0
    }
    
    func showToast(_ message: String, duration: TimeInterval = 2.0) {
        guard let window = mainWindow else { return }
        
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        let textSize = toastLabel.intrinsicContentSize
        let labelWidth = min(textSize.width + 40, screenBounds.width - 40)
        
        toastLabel.frame = CGRect(
            x: (screenBounds.width - labelWidth) / 2,
            y: screenBounds.height - 150,
            width: labelWidth,
            height: 40
        )
        
        window.addSubview(toastLabel)
        
        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: duration, options: [], animations: {
                toastLabel.alpha = 0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
    
    func showAlert(title: String, message: String, action: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            action?()
        })
        
        mainWindow?.rootViewController?.present(alert, animated: true)
    }
    
    func showConfirmation(title: String, message: String, confirmTitle: String = "Confirm", cancelTitle: String = "Cancel", onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel))
        alert.addAction(UIAlertAction(title: confirmTitle, style: .destructive) { _ in
            onConfirm()
        })
        
        mainWindow?.rootViewController?.present(alert, animated: true)
    }
}

extension UIWindow {
    static var current: UIWindow? {
        SceneDelegate.shared?.window
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    static var shared: SceneDelegate?
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        WindowManager.shared.configure(with: windowScene)
        
        self.window = windowScene.windows.first
        SceneDelegate.shared = self
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}