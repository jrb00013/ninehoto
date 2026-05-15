import Foundation

final class VersionManager {
    static let shared = VersionManager()
    
    private init() {}
    
    struct Version: Comparable {
        let major: Int
        let minor: Int
        let patch: Int
        
        init(_ string: String) {
            let parts = string.split(separator: ".").compactMap { Int($0) }
            major = parts.count > 0 ? parts[0] : 0
            minor = parts.count > 1 ? parts[1] : 0
            patch = parts.count > 2 ? parts[2] : 0
        }
        
        static func < (lhs: Version, rhs: Version) -> Bool {
            if lhs.major != rhs.major { return lhs.major < rhs.major }
            if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
            return lhs.patch < rhs.patch
        }
        
        var string: String {
            "\(major).\(minor).\(patch)"
        }
    }
    
    var currentVersion: Version {
        Version(Bundle.main.appVersion)
    }
    
    var buildNumber: String {
        Bundle.main.buildNumber
    }
    
    func isUpdateAvailable(from storedVersion: String) -> Bool {
        let stored = Version(storedVersion)
        return currentVersion > stored
    }
    
    var isFirstLaunch: Bool {
        let key = "has_launched_before"
        if UserDefaults.standard.bool(forKey: key) {
            return false
        }
        UserDefaults.standard.set(true, forKey: key)
        return true
    }
}

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var fullVersion: String {
        "\(appVersion) (\(buildNumber))"
    }
}