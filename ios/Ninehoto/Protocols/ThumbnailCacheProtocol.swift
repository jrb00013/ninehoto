import UIKit
import Photos

protocol ThumbnailCacheProtocol {
    func prefetch(_ assets: [PHAsset], service: PhotoLibraryServiceProtocol) async
    func clear() async
    func thumbnail(for asset: PHAsset) -> UIImage?
}