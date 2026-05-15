import Foundation

final class AppValidator {
    static let shared = AppValidator()
    
    private init() {}
    
    func validateAppIntegrity() -> ValidationResult {
        var issues: [String] = []
        
        // Check bundle identifier
        if Bundle.main.bundleIdentifier == nil {
            issues.append("Missing bundle identifier")
        }
        
        // Check minimum iOS version
        let systemVersion = UIDevice.current.systemVersion
        if let version = Double(systemVersion.split(separator: ".").first ?? "0"), version < 16.0 {
            issues.append("iOS version below minimum")
        }
        
        return issues.isEmpty ? .valid : .invalid(issues)
    }
    
    func validateBuild() -> Bool {
        #if DEBUG
        return true
        #else
        return Bundle.main.appVersion != "1.0.0"
        #endif
    }
}

enum ValidationResult {
    case valid
    case invalid([String])
}

import UIKit