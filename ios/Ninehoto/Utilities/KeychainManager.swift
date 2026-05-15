import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()
    
    private let service = "com.ninehoto.app"
    
    private init() {}
    
    func save(_ data: Data, forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func load(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }
    
    func delete(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    func saveString(_ string: String, forKey key: String) -> Bool {
        guard let data = string.data(using: .utf8) else { return false }
        return save(data, forKey: key)
    }
    
    func loadString(forKey key: String) -> String? {
        guard let data = load(forKey: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func saveCodable<T: Codable>(_ object: T, forKey key: String) -> Bool {
        guard let data = try? JSONEncoder().encode(object) else { return false }
        return save(data, forKey: key)
    }
    
    func loadCodable<T: Codable>(forKey key: String, type: T.Type) -> T? {
        guard let data = load(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}

extension KeychainManager {
    private var authTokenKey: String { "auth_token" }
    private var refreshTokenKey: String { "refresh_token" }
    
    var authToken: String? {
        get { loadString(forKey: authTokenKey) }
        set {
            if let value = newValue {
                saveString(value, forKey: authTokenKey)
            } else {
                delete(forKey: authTokenKey)
            }
        }
    }
    
    var refreshToken: String? {
        get { loadString(forKey: refreshTokenKey) }
        set {
            if let value = newValue {
                saveString(value, forKey: refreshTokenKey)
            } else {
                delete(forKey: refreshTokenKey)
            }
        }
    }
    
    func clearTokens() {
        _ = delete(forKey: authTokenKey)
        _ = delete(forKey: refreshTokenKey)
    }
}