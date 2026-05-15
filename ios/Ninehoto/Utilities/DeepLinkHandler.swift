import Foundation

enum DeepLink: String {
    case home
    case settings
    case statistics
    case about
    
    case swipeSession
    case finishConfirmation
    
    case unknown
    
    init(url: URL) {
        guard let host = url.host else {
            self = .unknown
            return
        }
        
        switch host {
        case "home": self = .home
        case "settings": self = .settings
        case "statistics": self = .statistics
        case "about": self = .about
        case "session": self = .swipeSession
        case "finish": self = .finishConfirmation
        default: self = .unknown
        }
    }
    
    var path: String {
        switch self {
        case .home: return "/"
        case .settings: return "/settings"
        case .statistics: return "/statistics"
        case .about: return "/about"
        case .swipeSession: return "/session"
        case .finishConfirmation: return "/session/finish"
        case .unknown: return ""
        }
    }
}

final class DeepLinkHandler {
    static let shared = DeepLinkHandler()
    
    private init() {}
    
    func handle(_ url: URL) -> Bool {
        let deepLink = DeepLink(url: url)
        
        guard deepLink != .unknown else {
            Logger.shared.warning("Unknown deep link: \(url)")
            return false
        }
        
        Logger.shared.info("Handling deep link: \(deepLink.rawValue)")
        
        switch deepLink {
        case .settings:
            return navigateToSettings()
        case .statistics:
            return navigateToStatistics()
        case .about:
            return navigateToAbout()
        default:
            return true
        }
    }
    
    private func navigateToSettings() -> Bool {
        NotificationCenter.default.post(name: .navigateToSettings, object: nil)
        return true
    }
    
    private func navigateToStatistics() -> Bool {
        NotificationCenter.default.post(name: .navigateToStatistics, object: nil)
        return true
    }
    
    private func navigateToAbout() -> Bool {
        NotificationCenter.default.post(name: .navigateToAbout, object: nil)
        return true
    }
}

extension Notification.Name {
    static let navigateToSettings = Notification.Name("navigateToSettings")
    static let navigateToStatistics = Notification.Name("navigateToStatistics")
    static let navigateToAbout = Notification.Name("navigateToAbout")
}