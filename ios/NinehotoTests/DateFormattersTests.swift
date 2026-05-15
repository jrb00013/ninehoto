import XCTest
@testable import Ninehoto

final class DateFormattersTests: XCTestCase {
    
    var dateFormatters: DateFormatters!
    
    override func setUp() {
        super.setUp()
        dateFormatters = DateFormatters.shared
    }
    
    func testFormat() {
        let date = Date()
        let formatted = dateFormatters.format(date)
        XCTAssertFalse(formatted.isEmpty)
    }
    
    func testFormatShort() {
        let date = Date()
        let formatted = dateFormatters.formatShort(date)
        XCTAssertFalse(formatted.isEmpty)
    }
    
    func testFormatRelative() {
        let date = Date()
        let formatted = dateFormatters.formatRelative(date)
        XCTAssertFalse(formatted.isEmpty)
    }
    
    func testFormatISO8601() {
        let date = Date()
        let formatted = dateFormatters.formatISO8601(date)
        XCTAssertFalse(formatted.isEmpty)
    }
    
    func testFormatTime() {
        let date = Date()
        let formatted = dateFormatters.formatTime(date)
        XCTAssertFalse(formatted.isEmpty)
    }
    
    func testParse() {
        let date = Date()
        let formatted = dateFormatters.format(date)
        let parsed = dateFormatters.parse(formatted)
        XCTAssertNotNil(parsed)
    }
    
    func testParseISO8601() {
        let date = Date()
        let formatted = dateFormatters.formatISO8601(date)
        let parsed = dateFormatters.parseISO8601(formatted)
        XCTAssertNotNil(parsed)
    }
    
    func testTimeAgoJustNow() {
        let recentDate = Date()
        let timeAgo = dateFormatters.timeAgo(recentDate)
        XCTAssertEqual(timeAgo, "Just now")
    }
    
    func testTimeAgoMinutes() {
        let minutesAgo = Date().addingTimeInterval(-300) // 5 minutes
        let timeAgo = dateFormatters.timeAgo(minutesAgo)
        XCTAssertTrue(timeAgo.contains("minute"))
    }
    
    func testTimeAgoHours() {
        let hoursAgo = Date().addingTimeInterval(-7200) // 2 hours
        let timeAgo = dateFormatters.timeAgo(hoursAgo)
        XCTAssertTrue(timeAgo.contains("hour"))
    }
    
    func testTimeAgoDays() {
        let daysAgo = Date().addingTimeInterval(-172800) // 2 days
        let timeAgo = dateFormatters.timeAgo(daysAgo)
        XCTAssertTrue(timeAgo.contains("day"))
    }
    
    func testDateExtensions() {
        let date = Date()
        
        XCTAssertFalse(date.formatted.isEmpty)
        XCTAssertFalse(date.formattedShort.isEmpty)
        XCTAssertFalse(date.formattedRelative.isEmpty)
        XCTAssertFalse(date.formattedISO8601.isEmpty)
        XCTAssertFalse(date.formattedTime.isEmpty)
        XCTAssertFalse(date.timeAgo.isEmpty)
    }
}

final class FeatureFlagsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        FeatureFlags.shared.resetAllFeatures()
    }
    
    override func tearDown() {
        FeatureFlags.shared.resetAllFeatures()
        super.tearDown()
    }
    
    func testDefaultFeatureFlags() {
        let flags = FeatureFlags.shared
        
        XCTAssertTrue(flags.isSwipeUndoEnabled)
        XCTAssertTrue(flags.isVideoSupportEnabled)
        XCTAssertTrue(flags.isHapticFeedbackEnabled)
        XCTAssertTrue(flags.isFullscreenPreviewEnabled)
    }
    
    func testSetFeature() {
        FeatureFlags.shared.setFeature("test_feature", enabled: false)
        XCTAssertFalse(FeatureFlags.shared.isFeatureEnabled("test_feature"))
        
        FeatureFlags.shared.setFeature("test_feature", enabled: true)
        XCTAssertTrue(FeatureFlags.shared.isFeatureEnabled("test_feature"))
    }
    
    func testResetAllFeatures() {
        FeatureFlags.shared.setFeature("test1", enabled: true)
        FeatureFlags.shared.setFeature("test2", enabled: true)
        
        FeatureFlags.shared.resetAllFeatures()
        
        XCTAssertFalse(FeatureFlags.shared.isFeatureEnabled("test1"))
        XCTAssertFalse(FeatureFlags.shared.isFeatureEnabled("test2"))
    }
    
    func testFeatureNameEnum() {
        let allCases = FeatureName.allCases
        XCTAssertTrue(allCases.contains(.swipeUndo))
        XCTAssertTrue(allCases.contains(.videoSupport))
        XCTAssertTrue(allCases.contains(.hapticFeedback))
    }
}