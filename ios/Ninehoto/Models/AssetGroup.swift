import Foundation
import Photos

enum GroupType: String {
    case burst
    case duplicate
    case single
}

struct AssetGroup: Identifiable {
    let id: String
    let assets: [PHAsset]
    let type: GroupType

    var count: Int { assets.count }
    var isMultiple: Bool { assets.count > 1 }
    var bestAsset: PHAsset { assets.first ?? assets[0] }
    var assetIds: [String] { assets.map(\.localIdentifier) }

    var formattedLabel: String {
        switch type {
        case .burst:
            return "Burst · \(count)"
        case .duplicate:
            return "\(count) duplicates"
        case .single:
            return ""
        }
    }

    init(assets: [PHAsset], type: GroupType) {
        let firstId = assets.first?.localIdentifier ?? UUID().uuidString
        self.id = "\(type.rawValue)_\(firstId)"
        self.assets = assets
        self.type = type
    }
}
