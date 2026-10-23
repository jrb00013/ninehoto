import Foundation
import Photos
import UIKit

protocol PhotoLibraryServiceProtocol {
    func currentAuthorizationStatus() -> PHAuthorizationStatus
    func requestAuthorization() async -> PHAuthorizationStatus
    func fetchRecentMedia(limit: Int) async -> [PHAsset]
    func requestFileSize(for asset: PHAsset) -> Int64
    func deleteAssets(_ assets: [PHAsset]) async throws
    func loadImage(for asset: PHAsset, targetSize: CGSize) async -> UIImage?
}

extension PhotoLibraryService: PhotoLibraryServiceProtocol {}