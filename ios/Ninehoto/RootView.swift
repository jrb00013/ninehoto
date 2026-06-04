import SwiftUI

struct RootView: View {
    @StateObject private var session = SwipeSessionViewModel()
    @State private var currentFilter = SessionFilter()

    var body: some View {
        Group {
            switch session.phase {
            case .mainMenu:
                MainMenuView(session: session, currentFilter: $currentFilter)
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
