import Foundation

final class MultiplatformManager {
    static let shared = MultiplatformManager()
    
    private init() {}
    
    enum Platform {
        case ios
        case android
        case macos
        case windows
        case linux
        case web
    }
    
    var currentPlatform: Platform {
        #if os(iOS)
        return .ios
        #elseif os(macOS)
        return .macos
        #elseif os(Windows)
        return .windows
        #elseif os(Linux)
        return .linux
        #else
        return .ios
        #endif
    }
    
    var isMobile: Bool {
        currentPlatform == .ios || currentPlatform == .android
    }
    
    var isDesktop: Bool {
        currentPlatform == .macos || currentPlatform == .windows || currentPlatform == .linux
    }
    
    func isAvailable(_ platform: Platform) -> Bool {
        // Check platform availability
        true
    }
    
    func getPlatformName() -> String {
        switch currentPlatform {
        case .ios: return "iOS"
        case .android: return "Android"
        case .macos: return "macOS"
        case .windows: return "Windows"
        case .linux: return "Linux"
        case .web: return "Web"
        }
    }
}