import Foundation
import Photos
import UIKit
import XCTest

final class MockPhotoLibraryService: PhotoLibraryServiceProtocol {
    var mockAuthorizationStatus: PHAuthorizationStatus = .authorized
    var mockAssets: [PHAsset] = []
    var shouldReturnError = false
    var errorToThrow: Error?

    var fetchCallCount = 0
    var deleteCallCount = 0
    var lastDeletedAssets: [PHAsset]?

    var currentAuthorizationStatus: PHAuthorizationStatus {
        mockAuthorizationStatus
    }

    func requestAuthorization() async -> PHAuthorizationStatus {
        return mockAuthorizationStatus
    }

    func fetchRecentMedia(limit: Int) async -> [PHAsset] {
        fetchCallCount += 1
        if shouldReturnError, let error = errorToThrow {
            throw error
        }
        return Array(mockAssets.prefix(limit))
    }

    func deleteAssets(_ assets: [PHAsset]) async throws {
        deleteCallCount += 1
        lastDeletedAssets = assets
        if shouldReturnError, let error = errorToThrow {
            throw error
        }
    }

    func fetchThumbnail(for asset: PHAsset, targetSize: CGSize) async -> UIImage? {
        return UIImage()
    }

    func addMockAsset(identifier: String, mediaType: PHMediaType = .image, creationDate: Date? = nil) {
        let asset = PHAsset()
        asset.setValue(identifier, forKey: "localIdentifier")
        asset.setValue(mediaType, forKey: "mediaType")
        if let date = creationDate {
            asset.setValue(date, forKey: "creationDate")
        }
        mockAssets.append(asset)
    }
}

final class MockThumbnailCache: ThumbnailCacheProtocol {
    var cachedImages: [String: UIImage] = [:]
    var prefetchCallCount = 0
    var clearCallCount = 0

    func prefetch(_ assets: [PHAsset], service: PhotoLibraryServiceProtocol) async {
        prefetchCallCount += 1
    }

    func clear() async {
        clearCallCount += 1
        cachedImages.removeAll()
    }

    func thumbnail(for asset: PHAsset) -> UIImage? {
        return cachedImages[asset.localIdentifier]
    }

    func addToCache(_ image: UIImage, forAssetId id: String) {
        cachedImages[id] = image
    }
}

final class MockLogger: LogLevel {
    var logMessages: [(level: LogLevel, message: String, file: String, function: String, line: Int)] = []

    static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        // Mock implementation
    }

    static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        // Mock implementation
    }

    static func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        // Mock implementation
    }

    static func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        // Mock implementation
    }
}