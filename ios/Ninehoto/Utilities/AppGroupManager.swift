import Foundation

final class AppGroupManager {
    static let shared = AppGroupManager()
    
    private let groupIdentifier = "group.com.ninehoto.app"
    
    private var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
    }
    
    private init() {}
    
    func save(_ data: Data, forKey key: String) throws {
        guard let url = containerURL?.appendingPathComponent(key) else {
            throw AppGroupError.containerNotAvailable
        }
        try data.write(to: url)
    }
    
    func load(forKey key: String) throws -> Data {
        guard let url = containerURL?.appendingPathComponent(key) else {
            throw AppGroupError.containerNotAvailable
        }
        return try Data(contentsOf: url)
    }
    
    func remove(forKey key: String) throws {
        guard let url = containerURL?.appendingPathComponent(key) else {
            throw AppGroupError.containerNotAvailable
        }
        try FileManager.default.removeItem(at: url)
    }
}

enum AppGroupError: Error {
    case containerNotAvailable
    case dataCorrupted
}