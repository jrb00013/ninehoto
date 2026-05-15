import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let asset: PHAsset
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    
    var body: some View {
        Group {
            if let player = player {
                VideoPlayer(player: player)
                    .onAppear {
                        player.play()
                        isPlaying = true
                    }
                    .onDisappear {
                        player.pause()
                        isPlaying = false
                    }
            } else {
                ProgressView()
                    .onAppear {
                        loadVideo()
                    }
            }
        }
        .overlay(playPauseOverlay)
    }
    
    private var playPauseOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Button(action: togglePlayback) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                }
            }
            Spacer()
        }
    }
    
    private func loadVideo() {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .automatic
        
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
            DispatchQueue.main.async {
                if let urlAsset = avAsset as? AVURLAsset {
                    self.player = AVPlayer(url: urlAsset.url)
                }
            }
        }
    }
    
    private func togglePlayback() {
        guard let player = player else { return }
        
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
}

struct VideoThumbnailView: View {
    let asset: PHAsset
    let thumbnail: UIImage?
    
    var body: some View {
        ZStack {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(Color.secondaryBackground)
            }
            
            playIconOverlay
            durationBadge
        }
    }
    
    private var playIconOverlay: some View {
        Image(systemName: "play.circle.fill")
            .font(.system(size: 50))
            .foregroundColor(.white.opacity(0.8))
    }
    
    private var durationBadge: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                if let duration = asset.duration {
                    Text(formatDuration(duration))
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(4)
                        .padding(8)
                }
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}