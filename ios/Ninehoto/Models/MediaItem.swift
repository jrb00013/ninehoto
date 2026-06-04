import Foundation
import Photos

struct MediaItem: Identifiable, Equatable {
    let id: String
    let asset: PHAsset
    let mediaType: MediaType
    let creationDate: Date?
    let duration: TimeInterval?
    let fileSize: Int64?

    enum MediaType: String {
        case photo
        case video
        case unknown
    }

    init(asset: PHAsset, fileSize: Int64? = nil) {
        self.id = asset.localIdentifier
        self.asset = asset
        self.fileSize = fileSize

        switch asset.mediaType {
        case .image:
            self.mediaType = .photo
        case .video:
            self.mediaType = .video
        default:
            self.mediaType = .unknown
        }

        self.creationDate = asset.creationDate
        self.duration = asset.duration
    }

    var isVideo: Bool {
        mediaType == .video
    }

    var formattedDuration: String? {
        guard let duration = duration else { return nil }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var formattedFileSize: String? {
        guard let fileSize else { return nil }
        return fileSize.formattedAsFileSize
    }

    var aspectRatio: CGFloat {
        let width = asset.pixelWidth
        let height = asset.pixelHeight
        guard height > 0 else { return 1.0 }
        return CGFloat(width) / CGFloat(height)
    }

    var isPortrait: Bool {
        aspectRatio < 1.0
    }

    var isLandscape: Bool {
        aspectRatio > 1.0
    }

    var isSquare: Bool {
        abs(aspectRatio - 1.0) < 0.01
    }
}

extension Int64 {
    var formattedAsFileSize: String {
        if self < 1024 { return "\(self) B" }
        if self < 1024 * 1024 { return String(format: "%.1f KB", Double(self) / 1024) }
        if self < 1024 * 1024 * 1024 { return String(format: "%.1f MB", Double(self) / (1024 * 1024)) }
        return String(format: "%.1f GB", Double(self) / (1024 * 1024 * 1024))
    }
}