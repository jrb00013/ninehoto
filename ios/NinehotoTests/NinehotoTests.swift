import XCTest

final class NinehotoTests: XCTestCase {
    func testAppInfo() {
        XCTAssertEqual(SwipeSessionViewModel.sessionLimit, 200)
    }
}
