import XCTest
@testable import Ninehoto

final class PhotoLibraryServiceTests: XCTestCase {
    func testServiceCanBeInstantiated() {
        let service = PhotoLibraryService()
        XCTAssertNotNil(service)
    }

    func testPhotoLibraryErrorExists() {
        let error = PhotoLibraryError.notAuthorized
        XCTAssertNotNil(error)
    }
}
