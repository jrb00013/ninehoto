import Foundation

final class AppStorageManager {
    static let shared = AppStorageManager()
    
    private init() {}
    
    func getStorageUsage() -> StorageUsage {
        let documents = getDirectorySize(.documentDirectory)
        let caches = getDirectorySize(.cachesDirectory)
        let temp = getDirectorySize(.temporaryDirectory)
        
        return StorageUsage(
            documents: documents,
            caches: caches,
            temporary: temp,
            total: documents + caches + temp
        )
    }
    
    private func getDirectorySize(_ directory: FileManager.SearchPathDirectory) -> Int64 {
        let url = FileManager.default.urls(for: directory, in: .userDomainMask)[0]
        return calculateDirectorySize(url)
    }
    
    private func calculateDirectorySize(_ url: URL) -> Int64 {
        var size: Int64 = 0
        
        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey]) {
            while let fileURL = enumerator.nextObject() as? URL {
                if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    size += Int64(fileSize)
                }
            }
        }
        
        return size
    }
    
    func clearTemporaryStorage() {
        let tempURL = FileManager.default.temporaryDirectory
        if let files = try? FileManager.default.contentsOfDirectory(at: tempURL, includingPropertiesForKeys: nil) {
            for file in files {
                try? FileManager.default.removeItem(at: file)
            }
        }
    }
}

struct StorageUsage {
    let documents: Int64
    let caches: Int64
    let temporary: Int64
    let total: Int64
    
    var formattedTotal: String { ByteCountFormatter.string(fromByteCount: total, countStyle: .file) }
}