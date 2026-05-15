import XCTest
@testable import Ninehoto

final class AnalyticsServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        AnalyticsService.shared.clearEvents()
    }
    
    override func tearDown() {
        AnalyticsService.shared.clearEvents()
        super.tearDown()
    }
    
    func testTrackSessionStart() {
        AnalyticsService.shared.trackSessionStart()
        
        let events = AnalyticsService.shared.getEvents()
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.name, "session_start")
    }
    
    func testTrackSessionEnd() {
        AnalyticsService.shared.trackSessionEnd(swipeCount: 100, deleteCount: 30, keepCount: 70)
        
        let events = AnalyticsService.shared.getEvents()
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.name, "session_end")
    }
    
    func testTrackSwipeLeft() {
        AnalyticsService.shared.trackSwipe(direction: .left, index: 5)
        
        let events = AnalyticsService.shared.getEvents()
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.name, "swipe")
    }
    
    func testTrackSwipeRight() {
        AnalyticsService.shared.trackSwipe(direction: .right, index: 10)
        
        let events = AnalyticsService.shared.getEvents()
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.name, "swipe")
    }
    
    func testTrackUndo() {
        AnalyticsService.shared.trackUndo()
        
        let events = AnalyticsService.shared.getEvents()
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.name, "undo")
    }
    
    func testTrackDeleteConfirmation() {
        AnalyticsService.shared.trackDeleteConfirmation(count: 5)
        
        let events = AnalyticsService.shared.getEvents()
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.name, "delete_confirmation")
    }
    
    func testTrackDeleteSuccess() {
        AnalyticsService.shared.trackDeleteSuccess(count: 5)
        
        let events = AnalyticsService.shared.getEvents()
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.name, "delete_success")
    }
    
    func testTrackPermissionDenied() {
        AnalyticsService.shared.trackPermissionDenied()
        
        let events = AnalyticsService.shared.getEvents()
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.name, "permission_denied")
    }
    
    func testTrackError() {
        AnalyticsService.shared.trackError(error: .noPhotosFound)
        
        let events = AnalyticsService.shared.getEvents()
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.name, "error")
    }
    
    func testGetSessionCount() {
        AnalyticsService.shared.trackSessionStart()
        AnalyticsService.shared.trackSessionStart()
        AnalyticsService.shared.trackSessionStart()
        
        XCTAssertEqual(AnalyticsService.shared.getSessionCount(), 3)
    }
    
    func testGetTotalSwipes() {
        AnalyticsService.shared.trackSwipe(direction: .left, index: 0)
        AnalyticsService.shared.trackSwipe(direction: .right, index: 1)
        AnalyticsService.shared.trackSwipe(direction: .left, index: 2)
        
        XCTAssertEqual(AnalyticsService.shared.getTotalSwipes(), 3)
    }
    
    func testClearEvents() {
        AnalyticsService.shared.trackSessionStart()
        AnalyticsService.shared.trackSwipe(direction: .left, index: 0)
        
        AnalyticsService.shared.clearEvents()
        
        let events = AnalyticsService.shared.getEvents()
        XCTAssertEqual(events.count, 0)
    }
    
    func testEventHasTimestamp() {
        AnalyticsService.shared.trackSessionStart()
        
        let events = AnalyticsService.shared.getEvents()
        XCTAssertNotNil(events.first?.timestamp)
    }
}