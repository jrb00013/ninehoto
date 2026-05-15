import Foundation

final class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let memoryCache = NSCache<NSString, UIImage>()
    private let diskCacheURL: URL
    
    private init() {
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        diskCacheURL = cacheDir.appendingPathComponent("image_cache")
        
        try? FileManager.default.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
        
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 50 * 1024 * 1024
    }
    
    func cache(_ image: UIImage, forKey key: String) {
        memoryCache.setObject(image, forKey: key as NSString)
        
        let fileURL = diskCacheURL.appendingPathComponent(key.sha256Hash)
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: fileURL)
        }
    }
    
    func getImage(forKey key: String) -> UIImage? {
        if let cached = memoryCache.object(forKey: key as NSString) {
            return cached
        }
        
        let fileURL = diskCacheURL.appendingPathComponent(key.sha256Hash)
        if let data = try? Data(contentsOf: fileURL),
           let image = UIImage(data: data) {
            memoryCache.setObject(image, forKey: key as NSString)
            return image
        }
        
        return nil
    }
    
    func removeImage(forKey key: String) {
        memoryCache.removeObject(forKey: key as NSString)
        
        let fileURL = diskCacheURL.appendingPathComponent(key.sha256Hash)
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    func clearMemoryCache() {
        memoryCache.removeAllObjects()
    }
    
    func clearDiskCache() {
        if let files = try? FileManager.default.contentsOfDirectory(at: diskCacheURL, includingPropertiesForKeys: nil) {
            for file in files {
                try? FileManager.default.removeItem(at: file)
            }
        }
    }
    
    func clearAllCaches() {
        clearMemoryCache()
        clearDiskCache()
    }
}

extension String {
    var sha256Hash: String {
        let data = Data(self.utf8)
        var hash = [UInt8](repeating: 0, count: 32)
        
        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(data.count), &hash)
        }
        
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

import CommonCrypto
import UIKit