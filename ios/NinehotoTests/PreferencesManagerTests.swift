import XCTest
@testable import Ninehoto

final class PreferencesManagerTests: XCTestCase {
    
    var preferences: PreferencesManager!
    
    override func setUp() {
        super.setUp()
        preferences = PreferencesManager.shared
        preferences.clearAll()
    }
    
    override func tearDown() {
        preferences.clearAll()
        super.tearDown()
    }
    
    func testOnboardingDefault() {
        XCTAssertFalse(preferences.hasCompletedOnboarding)
    }
    
    func testSetOnboarding() {
        preferences.hasCompletedOnboarding = true
        XCTAssertTrue(preferences.hasCompletedOnboarding)
        
        preferences.hasCompletedOnboarding = false
        XCTAssertFalse(preferences.hasCompletedOnboarding)
    }
    
    func testLastSessionDateDefault() {
        XCTAssertNil(preferences.lastSessionDate)
    }
    
    func testSetLastSessionDate() {
        let testDate = Date()
        preferences.lastSessionDate = testDate
        XCTAssertEqual(preferences.lastSessionDate, testDate)
        
        preferences.lastSessionDate = nil
        XCTAssertNil(preferences.lastSessionDate)
    }
    
    func testSwipeCountDefault() {
        XCTAssertEqual(preferences.swipeCount, 0)
    }
    
    func testIncrementSwipeCount() {
        preferences.swipeCount = 10
        preferences.incrementSwipeCount()
        XCTAssertEqual(preferences.swipeCount, 11)
    }
    
    func testIncrementDeleteCount() {
        preferences.deleteCount = 5
        preferences.incrementDeleteCount()
        XCTAssertEqual(preferences.deleteCount, 6)
    }
    
    func testIncrementKeepCount() {
        preferences.keepCount = 7
        preferences.incrementKeepCount()
        XCTAssertEqual(preferences.keepCount, 8)
    }
    
    func testResetStatistics() {
        preferences.swipeCount = 100
        preferences.deleteCount = 30
        preferences.keepCount = 70
        
        preferences.resetStatistics()
        
        XCTAssertEqual(preferences.swipeCount, 0)
        XCTAssertEqual(preferences.deleteCount, 0)
        XCTAssertEqual(preferences.keepCount, 0)
    }
    
    func testSortOrderDefault() {
        XCTAssertEqual(preferences.preferredSortOrder, .dateDescending)
    }
    
    func testSetSortOrder() {
        preferences.preferredSortOrder = .dateAscending
        XCTAssertEqual(preferences.preferredSortOrder, .dateAscending)
        
        preferences.preferredSortOrder = .creationDateDescending
        XCTAssertEqual(preferences.preferredSortOrder, .creationDateDescending)
    }
    
    func testThumbnailQualityDefault() {
        XCTAssertEqual(preferences.thumbnailQuality, .medium)
    }
    
    func testSetThumbnailQuality() {
        preferences.thumbnailQuality = .low
        XCTAssertEqual(preferences.thumbnailQuality, .low)
        
        preferences.thumbnailQuality = .high
        XCTAssertEqual(preferences.thumbnailQuality, .high)
    }
    
    func testHapticFeedbackDefault() {
        preferences.clearAll()
        XCTAssertTrue(preferences.hapticFeedbackEnabled)
    }
    
    func testSetHapticFeedback() {
        preferences.hapticFeedbackEnabled = false
        XCTAssertFalse(preferences.hapticFeedbackEnabled)
        
        preferences.hapticFeedbackEnabled = true
        XCTAssertTrue(preferences.hapticFeedbackEnabled)
    }
    
    func testClearAll() {
        preferences.hasCompletedOnboarding = true
        preferences.swipeCount = 50
        preferences.deleteCount = 10
        preferences.keepCount = 40
        
        preferences.clearAll()
        
        XCTAssertFalse(preferences.hasCompletedOnboarding)
        XCTAssertEqual(preferences.swipeCount, 0)
        XCTAssertEqual(preferences.deleteCount, 0)
        XCTAssertEqual(preferences.keepCount, 0)
    }
}

final class HapticManagerTests: XCTestCase {
    
    var hapticManager: HapticManager!
    
    override func setUp() {
        super.setUp()
        hapticManager = HapticManager.shared
    }
    
    func testSharedInstance() {
        let instance1 = HapticManager.shared
        let instance2 = HapticManager.shared
        XCTAssertTrue(instance1 === instance2)
    }
    
    func testImpactStyles() {
        XCTAssertNotNil(hapticManager)
    }
    
    func testSwipeLeft() {
        hapticManager.swipeLeft()
    }
    
    func testSwipeRight() {
        hapticManager.swipeRight()
    }
    
    func testSuccess() {
        hapticManager.success()
    }
    
    func testWarning() {
        hapticManager.warning()
    }
    
    func testError() {
        hapticManager.error()
    }
    
    func testSelection() {
        hapticManager.selection()
    }
}