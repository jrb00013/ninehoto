import Photos
import SwiftUI
import UIKit

struct SwipeDeckView: View {
    @ObservedObject var session: SwipeSessionViewModel
    @State private var dragOffset: CGSize = .zero
    @State private var isAnimatingOut: Bool = false
    @State private var cardScale: CGFloat = 1.0
    @State private var cardOpacity: Double = 1.0
    @State private var showFullscreen: Bool = false
    @State private var fullscreenAsset: PHAsset?
    private let swipeThreshold: CGFloat = 120

    private var swipeDirection: SwipeDirection {
        if dragOffset.width < -40 { return .left }
        if dragOffset.width > 40 { return .right }
        return .none
    }

    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let selectionFeedback = UISelectionFeedbackGenerator()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if session.isLoading {
                loadingView
            } else if let asset = session.currentAsset {
                cardView(for: asset)
                    .scaleEffect(cardScale)
                    .opacity(cardOpacity)
                    .offset(dragOffset)
                    .rotationEffect(.degrees(Double(dragOffset.width / 20)))
                    .gesture(dragGesture(for: asset))
                    .overlay(badgeOverlay)
                    .onTapGesture {
                        fullscreenAsset = asset
                        showFullscreen = true
                    }
                    .onChange(of: session.currentIndex) { _, _ in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            dragOffset = .zero
                            cardScale = 1.0
                            cardOpacity = 1.0
                        }
                    }
            } else {
                emptyStateView
            }

            VStack {
                topBar
                Spacer()
                bottomBar
            }
        }
        .fullScreenCover(isPresented: $showFullscreen) {
            if let asset = fullscreenAsset {
                FullscreenMediaView(asset: asset, isPresented: $showFullscreen)
            }
        }
        .confirmationDialog(
            session.pendingDeleteCount > 0
                ? "Delete \(session.pendingDeleteCount) item(s)?"
                : "End session?",
            isPresented: $session.showFinishConfirmation,
            titleVisibility: .visible
        ) {
            if session.pendingDeleteCount > 0 {
                Button("Delete \(session.pendingDeleteCount) item(s)", role: .destructive) {
                    Task { await session.confirmFinishAndApplyDeletes() }
                }
            } else {
                Button("Back to main menu") {
                    Task { await session.confirmFinishAndApplyDeletes() }
                }
            }
            Button("Cancel", role: .cancel) {
                session.cancelFinish()
            }
        } message: {
            Text(
                session.pendingDeleteCount > 0
                    ? "This removes photos and videos from your library. Unreviewed items stay unchanged."
                    : "No items are marked for deletion. Unreviewed items stay unchanged."
            )
        }
        .onAppear {
            feedbackGenerator.prepare()
            selectionFeedback.prepare()
        }
    }

    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.white)
                .scaleEffect(1.5)
            Text("Loading…")
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)
            Text("No more items")
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text("You've reviewed everything.")
                .foregroundStyle(.white.opacity(0.6))
        }
    }

    @ViewBuilder
    private func cardView(for asset: PHAsset) -> some View {
        GeometryReader { geo in
            ZStack {
                Color(white: 0.08)
                SwipeCardContent(asset: asset, containerSize: geo.size)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 80)
    }

    private func dragGesture(for asset: PHAsset) -> some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
                let progress = abs(value.translation.width) / swipeThreshold
                cardScale = 1.0 - min(progress * 0.05, 0.05)
            }
            .onEnded { value in
                let w = value.translation.width
                if w < -swipeThreshold {
                    selectionFeedback.select()
                    animateOut(direction: .left) {
                        session.swipeLeft()
                    }
                } else if w > swipeThreshold {
                    selectionFeedback.select()
                    animateOut(direction: .right) {
                        session.swipeRight()
                    }
                } else {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        dragOffset = .zero
                        cardScale = 1.0
                    }
                }
            }
    }

    private func animateOut(direction: SwipeDirection, completion: @escaping () -> Void) {
        withAnimation(.easeOut(duration: 0.15)) {
            switch direction {
            case .left:
                dragOffset = CGSize(width: -500, height: 0)
            case .right:
                dragOffset = CGSize(width: 500, height: 0)
            case .none:
                break
            }
            cardOpacity = 0
            cardScale = 0.8
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            dragOffset = .zero
            cardScale = 1.0
            cardOpacity = 1.0
            completion()
        }
    }

    @ViewBuilder
    private var badgeOverlay: some View {
        let opacity = min(abs(dragOffset.width) / swipeThreshold, 1.0)
        HStack {
            Text("DELETE")
                .font(.title.bold())
                .foregroundStyle(.red)
                .padding()
                .rotationEffect(.degrees(-12))
                .opacity(swipeDirection == .left ? Double(opacity) : 0)

            Spacer()

            Text("KEEP")
                .font(.title.bold())
                .foregroundStyle(.green)
                .padding()
                .rotationEffect(.degrees(12))
                .opacity(swipeDirection == .right ? Double(opacity) : 0)
        }
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private var topBar: some View {
        HStack(spacing: 12) {
            Button("Done") {
                session.tapDone()
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)

            if session.canUndo {
                Button {
                    session.undoLastSwipe()
                } label: {
                    Label("Undo", systemImage: "arrow.uturn.backward")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
            }

            Spacer()

            if session.pendingDeleteCount > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "trash.fill")
                        .foregroundStyle(.red.opacity(0.9))
                    Text("\(session.pendingDeleteCount)")
                        .font(.caption.bold())
                        .foregroundStyle(.red)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var bottomBar: some View {
        HStack {
            Text("Marked: \(session.pendingDeleteCount)")
                .foregroundStyle(.white.opacity(0.9))
            Spacer()
            Text("\(session.remainingCount) remaining")
                .foregroundStyle(.white.opacity(0.7))
        }
        .font(.subheadline)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

private enum SwipeDirection {
    case left, right, none
}

private struct SwipeCardContent: View {
    let asset: PHAsset
    let containerSize: CGSize
    @State private var image: UIImage?
    @State private var isLoading = true

    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .tint(.white)
            } else if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                VStack(spacing: 8) {
                    Image(systemName: asset.mediaType == .video ? "video" : "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.white.opacity(0.4))
                    Text("Unable to load")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
                }
            }

            if asset.mediaType == .video {
                VStack {
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: "video.fill")
                        Text(formatDuration(asset.duration))
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.black.opacity(0.6), in: Capsule())
                    .padding(12)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            let targetSize = CGSize(
                width: containerSize.width * UIScreen.main.scale,
                height: containerSize.height * UIScreen.main.scale
            )
            let id = asset.localIdentifier
            if let cached = await ThumbnailCache.shared.image(for: id) {
                image = cached
                isLoading = false
            } else {
                let loaded = await PhotoLibraryService().loadImage(for: asset, targetSize: targetSize)
                image = loaded
                if let loaded {
                    await ThumbnailCache.shared.set(loaded, for: id)
                }
                isLoading = false
            }
        }
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

struct FullscreenMediaView: View {
    let asset: PHAsset
    @Binding var isPresented: Bool
    @State private var image: UIImage?
    @State private var isLoading = true

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if isLoading {
                ProgressView()
                    .tint(.white)
            } else if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }

            VStack {
                HStack {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    Spacer()
                }
                .padding()

                Spacer()

                if asset.mediaType == .video {
                    HStack(spacing: 6) {
                        Image(systemName: "video.fill")
                        Text(formatDuration(asset.duration))
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                }
            }
        }
        .task {
            let targetSize = CGSize(
                width: UIScreen.main.bounds.width * UIScreen.main.scale,
                height: UIScreen.main.bounds.height * UIScreen.main.scale
            )
            image = await PhotoLibraryService().loadImage(for: asset, targetSize: targetSize)
            isLoading = false
        }
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
