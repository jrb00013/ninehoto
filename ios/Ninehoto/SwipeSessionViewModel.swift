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
    @Published private(set) var groups: [AssetGroup] = []
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var pendingDeletionGroupIds: Set<String> = []
    @Published private(set) var fileSizes: [String: Int64] = [:]
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

    var currentGroup: AssetGroup? {
        guard currentIndex >= 0, currentIndex < groups.count else { return nil }
        return groups[currentIndex]
    }

    var remainingCount: Int {
        max(0, groups.count - currentIndex)
    }

    var pendingDeleteCount: Int {
        groups
            .filter { pendingDeletionGroupIds.contains($0.id) }
            .reduce(0) { $0 + $1.assets.count }
    }

    var totalPendingSize: Int64 {
        groups
            .filter { pendingDeletionGroupIds.contains($0.id) }
            .flatMap(\.assetIds)
            .reduce(0) { $0 + (fileSizes[$1] ?? 0) }
    }

    var formattedPendingSize: String {
        totalPendingSize.formattedAsFileSize
    }

    func fileSize(for asset: PHAsset) -> Int64? {
        fileSizes[asset.localIdentifier]
    }

    private var undoStack: [(index: Int, groupId: String)] = []

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

    func startSession(filter: SessionFilter = SessionFilter()) async {
        if authorizationState == .notDetermined {
            await requestAccess()
        }
        guard canStartSession else { return }

        isLoading = true
        defer { isLoading = false }

        var fetched = await photoService.fetchRecentMedia(limit: Self.sessionLimit)

        if let trip = filter.trip {
            fetched = fetched.filter { asset in
                guard let date = asset.creationDate else { return false }
                return trip.dateRange.contains(date)
            }
        }

        if let album = filter.album {
            let albumResult = PHAsset.fetchAssets(in: album, options: nil)
            var albumIds = Set<String>()
            albumResult.enumerateObjects { asset, _, _ in
                albumIds.insert(asset.localIdentifier)
            }
            fetched = fetched.filter { albumIds.contains($0.localIdentifier) }
        }

        for asset in fetched {
            fileSizes[asset.localIdentifier] = photoService.requestFileSize(for: asset)
        }
        guard !fetched.isEmpty else {
            resultMessage = "No photos or videos were found in your library."
            showResultAlert = true
            phase = .mainMenu
            return
        }

        if FeatureFlags.shared.isBurstGroupingEnabled {
            groups = DuplicateDetector.groupAssets(fetched)
        } else {
            groups = fetched.map { AssetGroup(assets: [$0], type: .single) }
        }

        currentIndex = 0
        pendingDeletionGroupIds = []
        undoStack = []
        canUndo = false
        phase = .swiping

        await prefetchNext()
    }

    private func prefetchNext() async {
        let start = currentIndex
        let end = min(start + 5, groups.count)
        guard end > start else { return }
        let toPrefetch = groups[start..<end].flatMap(\.assets)
        await ThumbnailCache.shared.prefetch(toPrefetch, service: photoService)
    }

    func swipeLeft() {
        guard let group = currentGroup else { return }
        if !pendingDeletionGroupIds.contains(group.id) {
            pendingDeletionGroupIds.insert(group.id)
            undoStack.append((currentIndex, group.id))
            canUndo = true
        }
        advance()
        Task { await prefetchNext() }
    }

    func swipeRight() {
        guard let group = currentGroup else { return }
        if pendingDeletionGroupIds.contains(group.id) {
            pendingDeletionGroupIds.remove(group.id)
            undoStack.append((currentIndex, group.id))
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
        if pendingDeletionGroupIds.contains(last.groupId) {
            pendingDeletionGroupIds.remove(last.groupId)
        } else {
            pendingDeletionGroupIds.insert(last.groupId)
        }
        canUndo = !undoStack.isEmpty
    }

    private func advance() {
        if currentIndex + 1 < groups.count {
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
        let markedGroups = groups.filter { pendingDeletionGroupIds.contains($0.id) }
        let allAssetIds = markedGroups.flatMap(\.assetIds)
        let toDelete = markedGroups.flatMap(\.assets)
        guard !toDelete.isEmpty else {
            resetToMainMenu()
            return
        }

        let savedBytes = allAssetIds.reduce(0 as Int64) { $0 + (fileSizes[$1] ?? 0) }

        do {
            try await photoService.deleteAssets(toDelete)
            resultMessage = "Deleted \(toDelete.count) item(s)."
            if savedBytes > 0 {
                resultMessage += " (\(savedBytes.formattedAsFileSize))"
            }
            var stats = SessionStatistics.empty
            stats.deleteCount = toDelete.count
            stats.spaceSavedBytes = savedBytes
            StatisticsTracker.shared.saveSession(stats)
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
        groups = []
        currentIndex = 0
        pendingDeletionGroupIds = []
        undoStack = []
        canUndo = false
        Task { await ThumbnailCache.shared.clear() }
    }

    func backToMenuWithoutDeleting() {
        showFinishConfirmation = false
        resetToMainMenu()
    }
}
