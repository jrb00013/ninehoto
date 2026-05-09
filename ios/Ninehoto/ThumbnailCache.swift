import Foundation
import Photos
import UIKit

actor ThumbnailCache {
    static let shared = ThumbnailCache()

    private var cache: [String: UIImage] = [:]
    private var inFlight: [String: Task<UIImage?, Never>] = [:]

    func image(for identifier: String) -> UIImage? {
        cache[identifier]
    }

    func set(_ image: UIImage, for identifier: String) {
        cache[identifier] = image
    }

    func load(
        for asset: PHAsset,
        targetSize: CGSize,
        service: PhotoLibraryService
    ) async -> UIImage? {
        let id = asset.localIdentifier
        if let cached = cache[id] {
            return cached
        }
        if let existing = inFlight[id] {
            return await existing.value
        }
        let task = Task {
            await service.loadImage(for: asset, targetSize: targetSize)
        }
        inFlight[id] = task
        let result = await task.value
        inFlight[id] = nil
        if let result {
            cache[id] = result
        }
        return result
    }

    func prefetch(_ assets: [PHAsset], service: PhotoLibraryService) {
        for asset in assets {
            let id = asset.localIdentifier
            guard cache[id] == nil, inFlight[id] == nil else { continue }
            let size = CGSize(width: 540, height: 960)
            Task {
                let _ = await load(for: asset, targetSize: size, service: service)
            }
        }
    }

    func clear() {
        cache.removeAll()
        inFlight.removeAll()
    }
}
