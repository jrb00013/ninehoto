import Foundation
import Photos

final class MockDataGenerator {
    static let shared = MockDataGenerator()

    private init() {}

    func generateMockAssets(count: Int, includeVideos: Bool = true) -> [PHAsset] {
        var assets: [PHAsset] = []

        for i in 0..<count {
            let asset = PHAsset()
            let identifier = "mock-asset-\(i)-\(UUID().uuidString)"

            asset.setValue(identifier, forKey: "localIdentifier")

            let isVideo = includeVideos && (i % 5 == 0)
            asset.setValue(isVideo ? PHAssetMediaType.video : PHAssetMediaType.image, forKey: "mediaType")

            let daysAgo = Double(i)
            let date = Date().addingTimeInterval(-daysAgo * 86400)
            asset.setValue(date, forKey: "creationDate")

            let width = Int.random(in: 1000...4000)
            let height = Int.random(in: 1000...4000)
            asset.setValue(width, forKey: "pixelWidth")
            asset.setValue(height, forKey: "pixelHeight")

            if isVideo {
                let duration = Double.random(in: 5...300)
                asset.setValue(duration, forKey: "duration")
            }

            assets.append(asset)
        }

        return assets
    }

    func generateMockMediaItems(count: Int, includeVideos: Bool = true) -> [MediaItem] {
        let assets = generateMockAssets(count: count, includeVideos: includeVideos)
        return assets.map { MediaItem(asset: $0) }
    }

    func generateMockStatistics(count: Int) -> [SessionStatistics] {
        var sessions: [SessionStatistics] = []

        for i in 0..<count {
            let swipeCount = Int.random(in: 20...200)
            let deleteCount = Int.random(in: 0...swipeCount)
            let keepCount = swipeCount - deleteCount
            let duration = Double.random(in: 60...600)

            let session = SessionStatistics(
                swipeCount: swipeCount,
                deleteCount: deleteCount,
                keepCount: keepCount,
                sessionDate: Date().addingTimeInterval(-Double(i) * 86400 * 7),
                durationSeconds: duration,
                averageSwipesPerMinute: swipeCount / (duration / 60)
            )
            sessions.append(session)
        }

        return sessions
    }

    func generateMockUserPreferences() -> UserPreferences {
        UserPreferences(
            hapticFeedbackEnabled: Bool.random(),
            thumbnailQuality: PreferencesManager.ThumbnailQuality.allCases.randomElement() ?? .medium,
            sortOrder: PreferencesManager.SortOrder.allCases.randomElement() ?? .dateDescending,
            hasCompletedOnboarding: true,
            lastSessionDate: Date().addingTimeInterval(-Double.random(in: 0...604800))
        )
    }
}

struct UserPreferences: Codable {
    let hapticFeedbackEnabled: Bool
    let thumbnailQuality: PreferencesManager.ThumbnailQuality
    let sortOrder: PreferencesManager.SortOrder
    let hasCompletedOnboarding: Bool
    let lastSessionDate: Date?
}