import Foundation

final class StringResourceManager {
    static let shared = StringResourceManager()
    
    private var strings: [String: [String: String]] = [:]
    
    private init() {
        loadDefaultStrings()
    }
    
    private func loadDefaultStrings() {
        strings["en"] = [
            "app_name": "ninehoto",
            "start": "Start",
            "settings": "Settings",
            "statistics": "Statistics",
            "about": "About",
            "delete": "Delete",
            "cancel": "Cancel",
            "confirm": "Confirm",
            "done": "Done",
            "error": "Error",
            "success": "Success"
        ]
    }
    
    func get(_ key: String, locale: String = "en") -> String {
        strings[locale]?[key] ?? key
    }
    
    func set(_ value: String, forKey key: String, locale: String = "en") {
        if strings[locale] == nil {
            strings[locale] = [:]
        }
        strings[locale]?[key] = value
    }
    
    func getAllStrings(for locale: String) -> [String: String] {
        strings[locale] ?? [:]
    }
}