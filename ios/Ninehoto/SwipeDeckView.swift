import Photos
import SwiftUI

struct SwipeDeckView: View {
    @ObservedObject var session: SwipeSessionViewModel
    @State private var dragOffset: CGSize = .zero
    private let swipeThreshold: CGFloat = 120

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if session.isLoading {
                ProgressView("Loading…")
                    .tint(.white)
            } else if let asset = session.currentAsset {
                SwipeCardView(asset: asset)
                    .offset(dragOffset)
                    .rotationEffect(.degrees(Double(dragOffset.width / 20)))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                let w = value.translation.width
                                if w < -swipeThreshold {
                                    withAnimation(.spring()) {
                                        dragOffset = CGSize(width: -500, height: 0)
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                        dragOffset = .zero
                                        session.swipeLeft()
                                    }
                                } else if w > swipeThreshold {
                                    withAnimation(.spring()) {
                                        dragOffset = CGSize(width: 500, height: 0)
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                        dragOffset = .zero
                                        session.swipeRight()
                                    }
                                } else {
                                    withAnimation(.spring()) {
                                        dragOffset = .zero
                                    }
                                }
                            }
                    )
                    .overlay(alignment: .leading) {
                        if dragOffset.width < -40 {
                            Text("DELETE")
                                .font(.title2.bold())
                                .foregroundStyle(.red)
                                .padding()
                                .rotationEffect(.degrees(-12))
                        }
                    }
                    .overlay(alignment: .trailing) {
                        if dragOffset.width > 40 {
                            Text("KEEP")
                                .font(.title2.bold())
                                .foregroundStyle(.green)
                                .padding()
                                .rotationEffect(.degrees(12))
                        }
                    }
            } else {
                Text("No more items")
                    .foregroundStyle(.white)
            }

            VStack {
                HStack {
                    Button("Done") {
                        session.tapDone()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    Spacer()
                }
                .padding()

                Spacer()

                HStack {
                    Text("Marked to delete: \(session.pendingDeleteCount)")
                        .foregroundStyle(.white.opacity(0.9))
                    Spacer()
                    Text("Remaining: \(session.remainingCount)")
                        .foregroundStyle(.white.opacity(0.7))
                }
                .font(.caption)
                .padding()
            }
        }
        .onAppear {
            if session.authorizationState == .notDetermined {
                Task { await session.requestAccess() }
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
                    ? "This removes photos and videos from your library. Unreviewed items stay unchanged. This cannot be undone from the app."
                    : "No items are marked for deletion. Unreviewed items stay unchanged."
            )
        }
    }
}

private struct SwipeCardView: View {
    let asset: PHAsset
    @State private var image: UIImage?
    private let service = PhotoLibraryService()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width, height: geo.size.height)
                } else {
                    ProgressView()
                        .tint(.white)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .task {
                let size = CGSize(width: geo.size.width * UIScreen.main.scale, height: geo.size.height * UIScreen.main.scale)
                image = await service.loadImage(for: asset, targetSize: size)
            }
        }
        .padding()
    }
}
