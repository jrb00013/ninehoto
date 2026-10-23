import UIKit
import Photos

protocol ThumbnailCacheProtocol {
    func prefetch(_ assets: [PHAsset], service: PhotoLibraryService) async
    func clear() async
}