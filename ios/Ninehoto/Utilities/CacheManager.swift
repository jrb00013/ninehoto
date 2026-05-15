import Foundation

final class CacheManager {
    static let shared = CacheManager()
    
    private let cache = NSCache<NSString, AnyObject>()
    private let userDefaults = UserDefaults.standard
    private let fileManager = FileManager.default
    
    private let memoryCacheKey = "cache_manager_memory"
    private let diskCacheKey = "cache_manager_disk"
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }
    
    func set(_ value: AnyObject, forKey key: String) {
        cache.setObject(value, forKey: key as NSString)
    }
    
    func get<T>(forKey key: String) -> T? {
        cache.object(forKey: key as NSString) as? T
    }
    
    func remove(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    func clearMemoryCache() {
        cache.removeAllObjects()
    }
    
    func setToDisk<T: Encodable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            userDefaults.set(data, forKey: "\(diskCacheKey)_\(key)")
        }
    }
    
    func getFromDisk<T: Decodable>(forKey key: String, type: T.Type) -> T? {
        guard let data = userDefaults.data(forKey: "\(diskCacheKey)_\(key)") else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
    
    func removeFromDisk(forKey key: String) {
        userDefaults.removeObject(forKey: "\(diskCacheKey)_\(key)")
    }
    
    func clearDiskCache() {
        let keys = userDefaults.dictionaryRepresentation().keys
        for key in keys where key.hasPrefix(diskCacheKey) {
            userDefaults.removeObject(forKey: key)
        }
    }
    
    func clearAll() {
        clearMemoryCache()
        clearDiskCache()
    }
    
    var memoryCacheSize: Int {
        Int(cache.totalCostLimit)
    }
    
    var diskCacheSize: Int {
        let keys = userDefaults.dictionaryRepresentation().keys.filter { $0.hasPrefix(diskCacheKey) }
        return keys.reduce(0) { total, key in
            if let data = userDefaults.data(forKey: key) {
                return total + data.count
            }
            return total
        }
    }
}

struct CachedValue<T: Codable>: Codable {
    let value: T
    let timestamp: Date
    let expiresAt: Date?
    
    init(value: T, ttl: TimeInterval? = nil) {
        self.value = value
        self.timestamp = Date()
        self.expiresAt = ttl.map { Date().addingTimeInterval($0) }
    }
    
    var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() > expiresAt
    }
    
    static func cache(_ value: T, ttl: TimeInterval? = nil) -> CachedValue<T> {
        CachedValue(value: value, ttl: ttl)
    }
}

extension CacheManager {
    func cached<T: Codable>(_ value: T, forKey key: String, ttl: TimeInterval? = nil) {
        let cached = CachedValue(value: value, ttl: ttl)
        setToDisk(cached, forKey: key)
    }
    
    func getCached<T: Codable>(forKey key: String, type: T.Type) -> T? {
        guard let cached: CachedValue<T> = getFromDisk(forKey: key, type: CachedValue<T>.self) else {
            return nil
        }
        
        if cached.isExpired {
            removeFromDisk(forKey: key)
            return nil
        }
        
        return cached.value
    }
}