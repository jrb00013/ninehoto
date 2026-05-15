import SwiftUI
import Photos
import AVKit

struct FullscreenMediaView: View {
    let asset: PHAsset
    let onDismiss: () -> Void
    
    @State private var image: UIImage?
    @State private var videoPlayer: AVPlayer?
    @State private var isLoading = true
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .ignoresSafeArea()
                    .onTapGesture {
                        onDismiss()
                    }
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                } else {
                    if asset.mediaType == .video {
                        videoPlayerView(in: geometry)
                    } else {
                        imageView(in: geometry)
                    }
                }
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: onDismiss) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                    Spacer()
                    
                    if asset.mediaType == .video {
                        videoControls
                    }
                }
            }
        }
        .onAppear {
            loadMedia()
        }
        .gesture(magnificationGesture)
    }
    
    @ViewBuilder
    private func imageView(in geometry: GeometryProxy) -> some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .offset(offset)
                .gesture(dragGesture)
        }
    }
    
    @ViewBuilder
    private func videoPlayerView(in geometry: GeometryProxy) -> some View {
        if let player = videoPlayer {
            VideoPlayer(player: player)
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .offset(offset)
                .gesture(dragGesture)
        }
    }
    
    private var videoControls: some View {
        HStack(spacing: 20) {
            Button(action: {
                videoPlayer?.seek(to: .zero)
            }) {
                Image(systemName: "backward.end.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            Button(action: {
                if videoPlayer?.rate == 0 {
                    videoPlayer?.play()
                } else {
                    videoPlayer?.pause()
                }
            }) {
                Image(systemName: videoPlayer?.rate == 0 ? "play.fill" : "pause.fill")
                    .font(.title)
                    .foregroundColor(.white)
            }
            
            Button(action: {
                if let duration = videoPlayer?.currentItem?.duration {
                    videoPlayer?.seek(to: duration)
                }
            }) {
                Image(systemName: "forward.end.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(20)
        .padding(.bottom, 30)
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = value.translation
            }
            .onEnded { value in
                withAnimation(.spring()) {
                    offset = .zero
                }
            }
    }
    
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = value
            }
            .onEnded { value in
                withAnimation(.spring()) {
                    if value < 1 {
                        scale = 1
                    } else if value > 3 {
                        scale = 3
                    }
                }
            }
    }
    
    private func loadMedia() {
        isLoading = true
        
        if asset.mediaType == .video {
            loadVideo()
        } else {
            loadImage()
        }
    }
    
    private func loadImage() {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        
        let targetSize = CGSize(width: UIScreen.main.bounds.width * 2, height: UIScreen.main.bounds.height * 2)
        
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFit,
            options: options
        ) { image, _ in
            DispatchQueue.main.async {
                self.image = image
                self.isLoading = false
            }
        }
    }
    
    private func loadVideo() {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .automatic
        
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
            DispatchQueue.main.async {
                if let urlAsset = avAsset as? AVURLAsset {
                    self.videoPlayer = AVPlayer(url: urlAsset.url)
                    self.isLoading = false
                }
            }
        }
    }
}

struct ZoomableScrollView<Content: View>: View {
    let content: Content
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView([.horizontal, .vertical]) {
                content
                    .scaleEffect(scale)
                    .gesture(magnificationGesture)
            }
        }
    }
    
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value
                scale = min(max(scale * delta, 1), 4)
            }
            .onEnded { _ in
                lastScale = 1
                if scale < 1 {
                    withAnimation(.spring()) {
                        scale = 1
                    }
                }
            }
    }
}