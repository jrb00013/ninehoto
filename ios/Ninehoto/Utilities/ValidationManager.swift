import Foundation

final class ValidationManager {
    static let shared = ValidationManager()
    
    private init() {}
    
    func validateEmail(_ email: String) -> ValidationResult {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        if predicate.evaluate(with: email) {
            return .valid
        }
        return .invalid("Invalid email format")
    }
    
    func validatePassword(_ password: String) -> ValidationResult {
        if password.count < 8 {
            return .invalid("Password must be at least 8 characters")
        }
        return .valid
    }
    
    func validateUsername(_ username: String) -> ValidationResult {
        if username.count < 3 {
            return .invalid("Username must be at least 3 characters")
        }
        if username.count > 20 {
            return .invalid("Username must be at most 20 characters")
        }
        return .valid
    }
    
    func validateURL(_ url: String) -> ValidationResult {
        guard let url = URL(string: url) else {
            return .invalid("Invalid URL format")
        }
        if url.scheme == nil || url.host == nil {
            return .invalid("Invalid URL: missing scheme or host")
        }
        return .valid
    }
    
    func validateRequired(_ value: String, fieldName: String) -> ValidationResult {
        if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .invalid("\(fieldName) is required")
        }
        return .valid
    }
    
    func validateRange(_ value: Int, min: Int, max: Int, fieldName: String) -> ValidationResult {
        if value < min || value > max {
            return .invalid("\(fieldName) must be between \(min) and \(max)")
        }
        return .valid
    }
}

enum ValidationResult: Equatable {
    case valid
    case invalid(String)
    
    var isValid: Bool {
        if case .valid = self { return true }
        return false
    }
    
    var errorMessage: String? {
        if case .invalid(let message) = self { return message }
        return nil
    }
}