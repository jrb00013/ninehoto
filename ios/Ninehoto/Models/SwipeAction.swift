import Foundation

enum SwipeDirection: String, Codable {
    case left
    case right
    case up

    var isDeletion: Bool {
        self == .left
    }
}

struct SwipeAction: Identifiable, Codable, Equatable {
    let id: UUID
    let mediaId: String
    let direction: SwipeDirection
    let timestamp: Date
    let assetIndex: Int

    init(mediaId: String, direction: SwipeDirection, assetIndex: Int) {
        self.id = UUID()
        self.mediaId = mediaId
        self.direction = direction
        self.timestamp = Date()
        self.assetIndex = assetIndex
    }

    var isDelete: Bool {
        direction.isDeletion
    }
}

final class SwipeActionHistory {
    private var actions: [SwipeAction] = []
    private let maxHistory: Int = 1000

    func record(_ action: SwipeAction) {
        actions.append(action)
        if actions.count > maxHistory {
            actions.removeFirst(actions.count - maxHistory)
        }
    }

    func undo() -> SwipeAction? {
        return actions.popLast()
    }

    var canUndo: Bool {
        !actions.isEmpty
    }

    func clear() {
        actions.removeAll()
    }

    var count: Int {
        actions.count
    }

    var allActions: [SwipeAction] {
        actions
    }

    var deleteCount: Int {
        actions.filter { $0.isDelete }.count
    }

    var keepCount: Int {
        actions.filter { !$0.isDelete }.count
    }
}