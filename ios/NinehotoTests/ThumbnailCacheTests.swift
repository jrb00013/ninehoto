import XCTest
@testable import Ninehoto

final class ThumbnailCacheTests: XCTestCase {
    func testSessionLimitIsPositive() {
        XCTAssertGreaterThan(SwipeSessionViewModel.sessionLimit, 0)
    }

    func testSessionLimitUpperBound() {
        XCTAssertLessThan(SwipeSessionViewModel.sessionLimit, 10000)
    }
}
