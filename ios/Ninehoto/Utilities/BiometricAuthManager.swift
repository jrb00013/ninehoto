import Foundation

final class BiometricAuthManager {
    static let shared = BiometricAuthManager()
    
    private init() {}
    
    enum BiometricType {
        case none
        case touchID
        case faceID
    }
    
    var biometricType: BiometricType {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        switch context.biometryType {
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        case .opticID:
            return .faceID
        default:
            return .none
        }
    }
    
    var isBiometricAvailable: Bool {
        biometricType != .none
    }
    
    func authenticate(reason: String) async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return false
        }
        
        do {
            return try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
        } catch {
            Logger.shared.error("Biometric auth failed: \(error)")
            return false
        }
    }
}

import LocalAuthentication