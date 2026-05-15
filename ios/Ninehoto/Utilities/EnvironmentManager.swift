import Foundation

enum Environment: String {
    case development
    case staging
    case production
    
    var baseURL: String {
        switch self {
        case .development:
            return "https://dev.ninehoto.com"
        case .staging:
            return "https://staging.ninehoto.com"
        case .production:
            return "https://ninehoto.com"
        }
    }
    
    var isDebugEnabled: Bool {
        self != .production
    }
    
    var supportsAnalytics: Bool {
        self == .production
    }
    
    var logLevel: LogLevel {
        switch self {
        case .development: return .debug
        case .staging: return .info
        case .production: return .warning
        }
    }
}

final class EnvironmentManager {
    static let shared = EnvironmentManager()
    
    private let userDefaults = UserDefaults.standard
    private let environmentKey = "app_environment"
    
    private init() {}
    
    var current: Environment {
        get {
            guard let rawValue = userDefaults.string(forKey: environmentKey),
                  let env = Environment(rawValue: rawValue) else {
                return .development
            }
            return env
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: environmentKey)
            configureEnvironment(newValue)
        }
    }
    
    private func configureEnvironment(_ env: Environment) {
        Logger.shared.configure(minimumLevel: env.logLevel)
        
        if FeatureFlags.shared.isDebugLoggingEnabled {
            Logger.shared.configure(minimumLevel: .debug)
        }
        
        Logger.shared.info("Environment set to: \(env.rawValue)")
    }
    
    var isDevelopment: Bool { current == .development }
    var isStaging: Bool { current == .staging }
    var isProduction: Bool { current == .production }
    
    var apiBaseURL: String { current.baseURL }
}

extension EnvironmentManager {
    func setEnvironment(from launchOptions: [String: Any]?) {
        #if DEBUG
        current = .development
        #else
        if let envString = launchOptions?["ENVIRONMENT"] as? String,
           let env = Environment(rawValue: envString) {
            current = env
        } else {
            current = .production
        }
        #endif
    }
}