import SwiftUI
import Photos

struct SwipeCardView: View {
    let mediaItem: MediaItem
    let thumbnail: UIImage?
    let onSwipe: (SwipeDirection) -> Void

    @State private var offset: CGSize = .zero
    @State private var isDragging = false

    private let swipeThreshold: CGFloat = 100

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                thumbnailView(in: geometry)

                gradientOverlay

                if mediaItem.isVideo {
                    videoBadge
                }

                swipeIndicators
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            .offset(offset)
            .rotationEffect(.degrees(Double(offset.width / 20)))
            .gesture(dragGesture(in: geometry.size))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityDescription)
        }
    }

    @ViewBuilder
    private func thumbnailView(in geometry: GeometryProxy) -> some View {
        if let thumbnail = thumbnail {
            Image(uiImage: thumbnail)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
        } else {
            Rectangle()
                .fill(Color.secondaryBackground)
                .overlay(
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                )
        }
    }

    private var gradientOverlay: some View {
        LinearGradient(
            gradient: Gradient(colors: [.clear, .black.opacity(0.3)]),
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var videoBadge: some View {
        VStack {
            HStack {
                Spacer()
                if let duration = mediaItem.formattedDuration {
                    HStack(spacing: 4) {
                        Image(systemName: "play.fill")
                            .font(.caption2)
                        Text(duration)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                    .padding(12)
                }
            }
            Spacer()
        }
    }

    @ViewBuilder
    private var swipeIndicators: some View {
        HStack {
            if offset.width < -swipeThreshold / 2 {
                SwipeIndicator(direction: .left)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
            Spacer()
            if offset.width > swipeThreshold / 2 {
                SwipeIndicator(direction: .right)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 30)
    }

    private func dragGesture(in size: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                isDragging = true
                offset = value.translation
            }
            .onEnded { value in
                isDragging = false
                let horizontalAmount = value.translation.width

                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    if horizontalAmount < -swipeThreshold {
                        HapticManager.shared.swipeLeft()
                        onSwipe(.left)
                        offset = CGSize(width: -size.width * 1.5, height: 0)
                    } else if horizontalAmount > swipeThreshold {
                        HapticManager.shared.swipeRight()
                        onSwipe(.right)
                        offset = CGSize(width: size.width * 1.5, height: 0)
                    } else {
                        offset = .zero
                    }
                }
            }
    }

    private var accessibilityDescription: String {
        var description = mediaItem.isVideo ? "Video" : "Photo"
        if let date = mediaItem.creationDate {
            description += ", \(date.relativeFormatted)"
        }
        if mediaItem.isVideo, let duration = mediaItem.formattedDuration {
            description += ", duration \(duration)"
        }
        return description
    }
}

struct SwipeIndicator: View {
    let direction: SwipeDirection

    var body: some View {
        Image(systemName: direction == .left ? "xmark.circle.fill" : "checkmark.circle.fill")
            .font(.system(size: 60))
            .foregroundColor(direction == .left ? .destructiveRed : .keepGreen)
    }
}