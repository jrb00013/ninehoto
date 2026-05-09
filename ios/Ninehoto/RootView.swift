import SwiftUI

struct RootView: View {
    @StateObject private var session = SwipeSessionViewModel()

    var body: some View {
        Group {
            switch session.phase {
            case .mainMenu:
                MainMenuView(session: session)
            case .swiping:
                SwipeDeckView(session: session)
            }
        }
        .alert("Result", isPresented: $session.showResultAlert) {
            Button("OK", role: .cancel) {
                session.dismissResult()
            }
        } message: {
            Text(session.resultMessage)
        }
    }
}
