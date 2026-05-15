import XCTest
@testable import Ninehoto

final class ErrorTests: XCTestCase {

    func testPhotoLibraryAccessDeniedError() {
        let error = AppError.photoLibraryAccessDenied

        XCTAssertEqual(error.errorType, .photoLibraryAccessDenied)
        XCTAssertTrue(error.isRecoverable)
        XCTAssertEqual(error.localizedDescription, "Photo library access was denied. Please enable it in Settings.")
    }

    func testPhotoLibraryAccessRestrictedError() {
        let error = AppError.photoLibraryAccessRestricted

        XCTAssertEqual(error.errorType, .photoLibraryAccessRestricted)
        XCTAssertTrue(error.isRecoverable)
        XCTAssertEqual(error.localizedDescription, "Photo library access is restricted on this device.")
    }

    func testNoPhotosFoundError() {
        let error = AppError.noPhotosFound

        XCTAssertEqual(error.errorType, .noPhotosFound)
        XCTAssertTrue(error.isRecoverable)
        XCTAssertEqual(error.localizedDescription, "No photos or videos were found in your library.")
    }

    func testThumbnailLoadFailedError() {
        let error = AppError.thumbnailLoadFailed(assetId: "test-123")

        XCTAssertEqual(error.errorType, .thumbnailLoadFailed)
        XCTAssertTrue(error.isRecoverable)
        XCTAssertEqual(error.localizedDescription, "Failed to load thumbnail for asset: test-123")
    }

    func testDeletionFailedError() {
        let error = AppError.deletionFailed(count: 5, reason: "Permission denied")

        XCTAssertEqual(error.errorType, .deletionFailed)
        XCTAssertTrue(error.isRecoverable)
        XCTAssertEqual(error.localizedDescription, "Failed to delete 5 item(s): Permission denied")
    }

    func testSessionExpiredError() {
        let error = AppError.sessionExpired

        XCTAssertEqual(error.errorType, .sessionExpired)
        XCTAssertTrue(error.isRecoverable)
        XCTAssertEqual(error.localizedDescription, "Your session has expired. Please start again.")
    }

    func testUnknownError() {
        let underlyingError = NSError(domain: "test", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        let error = AppError.unknown(underlying: underlyingError)

        XCTAssertEqual(error.errorType, .unknown)
        XCTAssertTrue(error.isRecoverable)
        XCTAssertTrue(error.localizedDescription.contains("Test error"))
    }

    func testErrorEquality() {
        let error1 = AppError.photoLibraryAccessDenied
        let error2 = AppError.photoLibraryAccessDenied

        XCTAssertEqual(error1, error2)
    }

    func testErrorInequality() {
        let error1 = AppError.photoLibraryAccessDenied
        let error2 = AppError.noPhotosFound

        XCTAssertNotEqual(error1, error2)
    }

    func testAllErrorTypesAreRecoverable() {
        let errors: [AppError] = [
            .photoLibraryAccessDenied,
            .photoLibraryAccessRestricted,
            .noPhotosFound,
            .thumbnailLoadFailed(assetId: "test"),
            .deletionFailed(count: 1, reason: "test"),
            .sessionExpired
        ]

        for error in errors {
            XCTAssertTrue(error.isRecoverable, "\(error.errorType) should be recoverable")
        }
    }
}