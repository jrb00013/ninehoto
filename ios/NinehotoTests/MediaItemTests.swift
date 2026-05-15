import XCTest
import Photos
@testable import Ninehoto

final class MediaItemTests: XCTestCase {

    func testMediaItemInitialization() {
        let asset = createMockAsset(
            identifier: "test-123",
            mediaType: .image,
            pixelWidth: 1920,
            pixelHeight: 1080,
            duration: 0
        )

        let mediaItem = MediaItem(asset: asset)

        XCTAssertEqual(mediaItem.id, "test-123")
        XCTAssertEqual(mediaItem.mediaType, .photo)
        XCTAssertFalse(mediaItem.isVideo)
        XCTAssertEqual(mediaItem.aspectRatio, 16.0 / 9.0, accuracy: 0.01)
    }

    func testMediaItemVideoInitialization() {
        let asset = createMockAsset(
            identifier: "video-123",
            mediaType: .video,
            pixelWidth: 1920,
            pixelHeight: 1080,
            duration: 125.5
        )

        let mediaItem = MediaItem(asset: asset)

        XCTAssertEqual(mediaItem.id, "video-123")
        XCTAssertEqual(mediaItem.mediaType, .video)
        XCTAssertTrue(mediaItem.isVideo)
        XCTAssertEqual(mediaItem.formattedDuration, "2:05")
    }

    func testAspectRatioPortrait() {
        let asset = createMockAsset(
            identifier: "portrait",
            mediaType: .image,
            pixelWidth: 1080,
            pixelHeight: 1920,
            duration: 0
        )

        let mediaItem = MediaItem(asset: asset)

        XCTAssertTrue(mediaItem.isPortrait)
        XCTAssertFalse(mediaItem.isLandscape)
        XCTAssertFalse(mediaItem.isSquare)
        XCTAssert(mediaItem.aspectRatio < 1.0)
    }

    func testAspectRatioLandscape() {
        let asset = createMockAsset(
            identifier: "landscape",
            mediaType: .image,
            pixelWidth: 1920,
            pixelHeight: 1080,
            duration: 0
        )

        let mediaItem = MediaItem(asset: asset)

        XCTAssertFalse(mediaItem.isPortrait)
        XCTAssertTrue(mediaItem.isLandscape)
        XCTAssertFalse(mediaItem.isSquare)
        XCTAssert(mediaItem.aspectRatio > 1.0)
    }

    func testAspectRatioSquare() {
        let asset = createMockAsset(
            identifier: "square",
            mediaType: .image,
            pixelWidth: 1000,
            pixelHeight: 1000,
            duration: 0
        )

        let mediaItem = MediaItem(asset: asset)

        XCTAssertFalse(mediaItem.isPortrait)
        XCTAssertFalse(mediaItem.isLandscape)
        XCTAssertTrue(mediaItem.isSquare)
    }

    func testDurationFormatting() {
        let shortVideo = createMockAsset(identifier: "short", mediaType: .video, duration: 45)
        let mediaItem = MediaItem(asset: shortVideo)
        XCTAssertEqual(mediaItem.formattedDuration, "0:45")

        let mediumVideo = createMockAsset(identifier: "medium", mediaType: .video, duration: 125)
        let mediaItem2 = MediaItem(asset: mediumVideo)
        XCTAssertEqual(mediaItem2.formattedDuration, "2:05")

        let longVideo = createMockAsset(identifier: "long", mediaType: .video, duration: 3665)
        let mediaItem3 = MediaItem(asset: longVideo)
        XCTAssertEqual(mediaItem3.formattedDuration, "61:05")
    }

    func testEquality() {
        let asset1 = createMockAsset(identifier: "same-id", mediaType: .image)
        let asset2 = createMockAsset(identifier: "same-id", mediaType: .video)

        let item1 = MediaItem(asset: asset1)
        let item2 = MediaItem(asset: asset2)

        XCTAssertEqual(item1, item2)
    }

    func testInequality() {
        let asset1 = createMockAsset(identifier: "id-1", mediaType: .image)
        let asset2 = createMockAsset(identifier: "id-2", mediaType: .image)

        let item1 = MediaItem(asset: asset1)
        let item2 = MediaItem(asset: asset2)

        XCTAssertNotEqual(item1, item2)
    }

    private func createMockAsset(
        identifier: String,
        mediaType: PHMediaType,
        pixelWidth: Int = 1000,
        pixelHeight: Int = 1000,
        duration: TimeInterval = 0
    ) -> PHAsset {
        let asset = PHAsset()

        asset.setValue(identifier, forKey: "localIdentifier")
        asset.setValue(mediaType, forKey: "mediaType")
        asset.setValue(pixelWidth, forKey: "pixelWidth")
        asset.setValue(pixelHeight, forKey: "pixelHeight")

        if mediaType == .video {
            asset.setValue(duration, forKey: "duration")
        }

        return asset
    }
}