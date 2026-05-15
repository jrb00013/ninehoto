import Foundation

final class MediaMetadataExtractor {
    static let shared = MediaMetadataExtractor()
    
    private init() {}
    
    func extractMetadata(from url: URL) async -> MediaMetadata? {
        let asset = AVAsset(url: url)
        
        do {
            let duration = try await asset.load(.duration)
            let tracks = try await asset.load(.tracks)
            
            var metadata = MediaMetadata()
            metadata.duration = CMTimeGetSeconds(duration)
            
            for track in tracks {
                let mediaType = track.mediaType
                if mediaType == .video {
                    let size = try await track.load(.naturalSize)
                    metadata.width = Int(size.width)
                    metadata.height = Int(size.height)
                    metadata.bitrate = try await track.load(.estimatedDataRate)
                }
            }
            
            return metadata
        } catch {
            Logger.shared.error("Failed to extract metadata: \(error)")
            return nil
        }
    }
}

struct MediaMetadata {
    var duration: Double = 0
    var width: Int = 0
    var height: Int = 0
    var bitrate: Double = 0
    var codec: String?
    var frameRate: Float?
}

import AVFoundation