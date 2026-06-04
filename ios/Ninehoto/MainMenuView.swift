import SwiftUI
import Photos
import UIKit

struct MainMenuView: View {
    @ObservedObject var session: SwipeSessionViewModel
    @State private var showFilterSheet = false
    @Binding var currentFilter: SessionFilter

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "1A237E"), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 12) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 60))
                        .foregroundStyle(.white)
                        .symbolEffect(.pulse, options: .repeating)

                    Text("ninehoto")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Swipe left to lose it, right to keep it. Nothing is removed until you confirm.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                VStack(spacing: 16) {
                    if case .denied = session.authorizationState {
                        permissionBanner(
                            icon: "exclamationmark.triangle.fill",
                            message: "Photo library access denied. Enable it in Settings.",
                            color: .red
                        )
                    } else if case .restricted = session.authorizationState {
                        permissionBanner(
                            icon: "lock.fill",
                            message: "Photo library access is restricted.",
                            color: .orange
                        )
                    } else if case .notDetermined = session.authorizationState {
                        permissionBanner(
                            icon: "photo.on.rectangle",
                            message: "We need photo library access to get started.",
                            color: .blue
                        )
                    }

                    Button {
                        Task { await session.startSession(filter: currentFilter) }
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text(currentFilter.isActive ? "Start (\(currentFilter.label))" : "Start Cleaning")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .controlSize(.large)
                    .padding(.horizontal, 48)
                    .disabled(!session.canStartSession)

                    if FeatureFlags.shared.isTripFilteringEnabled {
                        Button {
                            showFilterSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                Text(currentFilter.isActive ? "Filter: \(currentFilter.label)" : "Filter")
                            }
                            .font(.subheadline)
                        }
                        .buttonStyle(.bordered)
                        .tint(.white.opacity(0.6))
                    }
                }

                VStack(spacing: 4) {
                    HStack(spacing: 8) {
                        swipeHint(icon: "arrow.left", text: "Left = delete", color: .red)
                        swipeHint(icon: "arrow.right", text: "Right = keep", color: .green)
                    }

                    Text("Showing up to \(SwipeSessionViewModel.sessionLimit) newest photos and videos")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.4))
                }

                Spacer()
                Spacer()
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterSelectionView(filter: $currentFilter)
        }
        .task {
            if session.authorizationState == .notDetermined {
                await session.requestAccess()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            session.refreshAuthorization()
        }
    }

    @ViewBuilder
    private func permissionBanner(icon: String, message: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(message)
                .font(.callout)
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 32)
    }

    @ViewBuilder
    private func swipeHint(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.caption)
        .foregroundStyle(color.opacity(0.8))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.15), in: Capsule())
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
