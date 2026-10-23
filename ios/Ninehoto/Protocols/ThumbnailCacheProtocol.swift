import UIKit
import Photos

protocol ThumbnailCacheProtocol {
    func prefetch(_ assets: [PHAsset], service: PhotoLibraryService)
    func clear()
}