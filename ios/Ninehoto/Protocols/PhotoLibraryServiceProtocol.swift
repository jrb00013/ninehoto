import Foundation
import Photos

protocol PhotoLibraryServiceProtocol {
    var currentAuthorizationStatus: PHAuthorizationStatus { get }
    func requestAuthorization() async -> PHAuthorizationStatus
    func fetchRecentMedia(limit: Int) async -> [PHAsset]
    func deleteAssets(_ assets: [PHAsset]) async throws
    func fetchThumbnail(for asset: PHAsset, targetSize: CGSize) async -> UIImage?
}

extension PhotoLibraryService: PhotoLibraryServiceProtocol {}