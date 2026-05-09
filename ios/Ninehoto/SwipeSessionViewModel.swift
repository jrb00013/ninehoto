import Foundation
import Photos
import SwiftUI

enum AppPhase {
    case mainMenu
    case swiping
}

@MainActor
final class SwipeSessionViewModel: ObservableObject {
    static let sessionLimit = 200

    @Published private(set) var phase: AppPhase = .mainMenu
    @Published private(set) var authorizationState: PHAuthorizationStatus = .notDetermined
    @Published private(set) var assets: [PHAsset] = []
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var pendingDeletionIds: Set<String> = []
    @Published var showFinishConfirmation = false
    @Published var showResultAlert = false
    @Published var resultMessage = ""
    @Published var isLoading = false
    @Published private(set) var canUndo: Bool = false

    private let photoService = PhotoLibraryService()

    var canStartSession: Bool {
        switch authorizationState {
        case .denied, .restricted:
            return false
        default:
            return true
        }
    }

    var currentAsset: PHAsset? {
        guard currentIndex >= 0, currentIndex < assets.count else { return nil }
        return assets[currentIndex]
    }

    var remainingCount: Int {
        max(0, assets.count - currentIndex)
    }

    var pendingDeleteCount: Int {
        pendingDeletionIds.count
    }

    private var undoStack: [(index: Int, id: String)] = []

    init() {
        authorizationState = photoService.currentAuthorizationStatus()
    }

    func refreshAuthorization() {
        authorizationState = photoService.currentAuthorizationStatus()
    }

    func requestAccess() async {
        let status = await photoService.requestAuthorization()
        authorizationState = status
    }

    func startSession() async {
        if authorizationState == .notDetermined {
            await requestAccess()
        }
        guard canStartSession else { return }

        isLoading = true
        defer { isLoading = false }

        let fetched = await photoService.fetchRecentMedia(limit: Self.sessionLimit)
        guard !fetched.isEmpty else {
            resultMessage = "No photos or videos were found in your library."
            showResultAlert = true
            phase = .mainMenu
            return
        }
        assets = fetched
        currentIndex = 0
        pendingDeletionIds = []
        undoStack = []
        canUndo = false
        phase = .swiping

        await prefetchNext()
    }

    private func prefetchNext() async {
        let start = currentIndex
        let end = min(start + 5, assets.count)
        guard end > start else { return }
        let toPrefetch = Array(assets[start..<end])
        await ThumbnailCache.shared.prefetch(toPrefetch, service: photoService)
    }

    func swipeLeft() {
        guard let asset = currentAsset else { return }
        let id = asset.localIdentifier
        if !pendingDeletionIds.contains(id) {
            pendingDeletionIds.insert(id)
            undoStack.append((currentIndex, id))
            canUndo = true
        }
        advance()
        Task { await prefetchNext() }
    }

    func swipeRight() {
        guard let asset = currentAsset else { return }
        let id = asset.localIdentifier
        if pendingDeletionIds.contains(id) {
            pendingDeletionIds.remove(id)
            undoStack.append((currentIndex, id))
            canUndo = true
        }
        advance()
        Task { await prefetchNext() }
    }

    func undoLastSwipe() {
        guard let last = undoStack.popLast() else { return }
        if currentIndex != last.index {
            currentIndex = last.index
        }
        if pendingDeletionIds.contains(last.id) {
            pendingDeletionIds.remove(last.id)
        } else {
            pendingDeletionIds.insert(last.id)
        }
        canUndo = !undoStack.isEmpty
    }

    private func advance() {
        if currentIndex + 1 < assets.count {
            currentIndex += 1
        } else {
            showFinishConfirmation = true
        }
    }

    func tapDone() {
        showFinishConfirmation = true
    }

    func cancelFinish() {
        showFinishConfirmation = false
    }

    func confirmFinishAndApplyDeletes() async {
        showFinishConfirmation = false
        let toDelete = assets.filter { pendingDeletionIds.contains($0.localIdentifier) }
        guard !toDelete.isEmpty else {
            resetToMainMenu()
            return
        }

        do {
            try await photoService.deleteAssets(toDelete)
            resultMessage = "Deleted \(toDelete.count) item(s)."
        } catch {
            resultMessage = "Some deletes may have failed: \(error.localizedDescription)"
        }
        showResultAlert = true
        resetToMainMenu()
    }

    func dismissResult() {
        showResultAlert = false
    }

    func resetToMainMenu() {
        phase = .mainMenu
        assets = []
        currentIndex = 0
        pendingDeletionIds = []
        undoStack = []
        canUndo = false
        Task { await ThumbnailCache.shared.clear() }
    }

    func backToMenuWithoutDeleting() {
        showFinishConfirmation = false
        resetToMainMenu()
    }
}
