import Foundation
import Photos

struct DuplicateDetector {
    static func groupAssets(_ assets: [PHAsset]) -> [AssetGroup] {
        var remaining = Set(assets.map { $0.localIdentifier })
        var groups: [AssetGroup] = []

        let assetMap = Dictionary(uniqueKeysWithValues: assets.map { ($0.localIdentifier, $0) })

        var burstGroups: [String: [PHAsset]] = [:]
        for asset in assets {
            if let burstId = asset.burstIdentifier {
                burstGroups[burstId, default: []].append(asset)
            }
        }

        for (_, burstAssets) in burstGroups where burstAssets.count > 1 {
            let sorted = burstAssets.sorted { $0.creationDate ?? .distantPast < $1.creationDate ?? .distantPast }
            groups.append(AssetGroup(assets: sorted, type: .burst))
            for asset in sorted {
                remaining.remove(asset.localIdentifier)
            }
        }

        let singles = remaining.compactMap { assetMap[$0] }
        let dateSorted = singles.sorted { ($0.creationDate ?? .distantPast) < ($1.creationDate ?? .distantPast) }

        var duplicateGroups: [[PHAsset]] = []
        var used = Set<String>()

        for i in 0..<dateSorted.count {
            let a = dateSorted[i]
            guard !used.contains(a.localIdentifier) else { continue }

            var group = [a]
            used.insert(a.localIdentifier)

            for j in (i + 1)..<dateSorted.count {
                let b = dateSorted[j]
                guard !used.contains(b.localIdentifier) else { continue }
                if areDuplicates(a, b) {
                    group.append(b)
                    used.insert(b.localIdentifier)
                }
            }

            if group.count > 1 {
                duplicateGroups.append(group)
            } else {
                groups.append(AssetGroup(assets: group, type: .single))
            }
        }

        for dupGroup in duplicateGroups {
            groups.append(AssetGroup(assets: dupGroup, type: .duplicate))
        }

        return groups
    }

    static func areDuplicates(_ a: PHAsset, _ b: PHAsset) -> Bool {
        guard let dateA = a.creationDate, let dateB = b.creationDate else {
            return false
        }

        let timeDelta = abs(dateA.timeIntervalSince(dateB))
        guard timeDelta < 3 else { return false }

        if let locA = a.location, let locB = b.location {
            let coordDelta = locA.distance(from: locB)
            guard coordDelta < 20 else { return false }
        }

        guard a.pixelWidth == b.pixelWidth, a.pixelHeight == b.pixelHeight else {
            return false
        }

        return true
    }
}
