import SwiftUI
import Photos
import UIKit

struct MainMenuView: View {
    @ObservedObject var session: SwipeSessionViewModel

    var body: some View {
        VStack(spacing: 24) {
            Text("ninehoto")
                .font(.largeTitle.bold())
            Text("Swipe left to lose it, right to keep it. Tap Done when you’re finished — nothing is removed until you confirm.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if case .denied = session.authorizationState {
                Text("Photo library access was denied. Enable it in Settings to use this app.")
                    .font(.callout)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else if case .restricted = session.authorizationState {
                Text("Photo library access is restricted on this device.")
                    .foregroundStyle(.orange)
            }

            Button {
                Task { await session.startSession() }
            } label: {
                Text("Start")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 32)
            .disabled(!session.canStartSession)

            Text("Showing up to \(SwipeSessionViewModel.sessionLimit) newest photos and videos.")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .task {
            if session.authorizationState == .notDetermined {
                await session.requestAccess()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            session.refreshAuthorization()
        }
    }
}
