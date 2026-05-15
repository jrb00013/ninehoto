import Foundation

struct AppCommand {
    let name: String
    let description: String
    let execute: () -> Void
}

final class CommandPalette {
    static let shared = CommandPalette()
    
    private var commands: [AppCommand] = []
    
    private init() {
        registerDefaultCommands()
    }
    
    private func registerDefaultCommands() {
        register(AppCommand(name: "clear_cache", description: "Clear image cache") {
            ImageCacheManager.shared.clearAllCaches()
        })
        
        register(AppCommand(name: "reset_stats", description: "Reset statistics") {
            PreferencesManager.shared.resetStatistics()
        })
        
        register(AppCommand(name: "refresh_session", description: "Restart session") {
            NotificationCenter.default.post(name: .refreshSession, object: nil)
        })
        
        register(AppCommand(name: "toggle_dark_mode", description: "Toggle dark mode") {
            ColorSchemeManager.shared.setDarkMode(!ColorSchemeManager.shared.isDarkMode)
        })
    }
    
    func register(_ command: AppCommand) {
        commands.append(command)
    }
    
    func execute(_ name: String) {
        commands.first { $0.name == name }?.execute()
    }
    
    func getCommands() -> [AppCommand] {
        commands
    }
}

extension Notification.Name {
    static let refreshSession = Notification.Name("refreshSession")
}