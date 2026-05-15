import Foundation

final class FileManager {
    static let shared = FileManager()
    
    private let fileManager = FileManager.default
    
    private init() {}
    
    var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    var cachesDirectory: URL {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }
    
    var tempDirectory: URL {
        fileManager.temporaryDirectory
    }
    
    func createDirectory(at url: URL) throws {
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    func write(_ data: Data, to url: URL) throws {
        try data.write(to: url)
    }
    
    func read(from url: URL) throws -> Data {
        try Data(contentsOf: url)
    }
    
    func delete(at url: URL) throws {
        try fileManager.removeItem(at: url)
    }
    
    func exists(at url: URL) -> Bool {
        fileManager.fileExists(atPath: url.path)
    }
    
    func fileSize(at url: URL) -> Int64? {
        guard let attributes = try? fileManager.attributesOfItem(atPath: url.path) else { return nil }
        return attributes[.size] as? Int64
    }
    
    func listFiles(in directory: URL) -> [URL] {
        guard let contents = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else {
            return []
        }
        return contents
    }
    
    func clearDirectory(_ directory: URL) {
        let files = listFiles(in: directory)
        for file in files {
            try? delete(at: file)
        }
    }
    
    func saveJSON<T: Encodable>(_ object: T, to filename: String) throws {
        let url = documentsDirectory.appendingPathComponent(filename)
        let data = try JSONEncoder().encode(object)
        try data.write(to: url)
    }
    
    func loadJSON<T: Decodable>(from filename: String, as type: T.Type) throws -> T {
        let url = documentsDirectory.appendingPathComponent(filename)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(type, from: data)
    }
}