import Foundation

final class KeyValueStore {
    static let shared = KeyValueStore()
    
    private let defaults = UserDefaults.standard
    private let prefix = "kv_"
    
    private init() {}
    
    func set(_ value: Any, forKey key: String) {
        defaults.set(value, forKey: prefix + key)
    }
    
    func get<T>(forKey key: String) -> T? {
        defaults.value(forKey: prefix + key) as? T
    }
    
    func remove(forKey key: String) {
        defaults.removeObject(forKey: prefix + key)
    }
    
    func getString(forKey key: String) -> String? {
        defaults.string(forKey: prefix + key)
    }
    
    func getInt(forKey key: String) -> Int? {
        defaults.object(forKey: prefix + key) as? Int
    }
    
    func getBool(forKey key: String) -> Bool? {
        defaults.object(forKey: prefix + key) as? Bool
    }
    
    func getData(forKey key: String) -> Data? {
        defaults.data(forKey: prefix + key)
    }
    
    func clearAll() {
        let keys = defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix(prefix) }
        keys.forEach { defaults.removeObject(forKey: $0) }
    }
}