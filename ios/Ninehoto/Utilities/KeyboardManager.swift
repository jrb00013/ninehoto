import SwiftUI

final class KeyboardManager: ObservableObject {
    static let shared = KeyboardManager()
    
    @Published var isVisible: Bool = false
    @Published var height: CGFloat = 0
    
    private init() {
        setupObservers()
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        height = keyboardFrame.height
        isVisible = true
        
        Logger.shared.debug("Keyboard shown: \(height)")
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        height = 0
        isVisible = false
        
        Logger.shared.debug("Keyboard hidden")
    }
    
    func dismiss() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct KeyboardAwareModifier: ViewModifier {
    @ObservedObject var keyboardManager = KeyboardManager.shared
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardManager.isVisible ? keyboardManager.height : 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: keyboardManager.isVisible)
    }
}

extension View {
    func keyboardAware() -> some View {
        modifier(KeyboardAwareModifier())
    }
    
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}