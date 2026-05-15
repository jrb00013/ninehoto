import XCTest
@testable import Ninehoto

final class StatisticsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        StatisticsTracker.shared.clearAll()
    }

    override func tearDown() {
        StatisticsTracker.shared.clearAll()
        super.tearDown()
    }

    func testEmptyStatistics() {
        let stats = SessionStatistics.empty

        XCTAssertEqual(stats.swipeCount, 0)
        XCTAssertEqual(stats.deleteCount, 0)
        XCTAssertEqual(stats.keepCount, 0)
        XCTAssertEqual(stats.deleteRate, 0)
        XCTAssertEqual(stats.keepRate, 0)
    }

    func testDeleteRateCalculation() {
        let stats = SessionStatistics(
            swipeCount: 100,
            deleteCount: 30,
            keepCount: 70,
            sessionDate: Date(),
            durationSeconds: 300,
            averageSwipesPerMinute: 20
        )

        XCTAssertEqual(stats.deleteRate, 30.0, accuracy: 0.01)
        XCTAssertEqual(stats.keepRate, 70.0, accuracy: 0.01)
    }

    func testDeleteRateWithZeroSwipes() {
        let stats = SessionStatistics(
            swipeCount: 0,
            deleteCount: 0,
            keepCount: 0,
            sessionDate: Date(),
            durationSeconds: 0,
            averageSwipesPerMinute: 0
        )

        XCTAssertEqual(stats.deleteRate, 0)
        XCTAssertEqual(stats.keepRate, 0)
    }

    func testFormattedDuration() {
        let shortStats = SessionStatistics(
            swipeCount: 10,
            deleteCount: 5,
            keepCount: 5,
            sessionDate: Date(),
            durationSeconds: 45,
            averageSwipesPerMinute: 13.3
        )
        XCTAssertEqual(shortStats.formattedDuration, "45s")

        let mediumStats = SessionStatistics(
            swipeCount: 50,
            deleteCount: 20,
            keepCount: 30,
            sessionDate: Date(),
            durationSeconds: 180,
            averageSwipesPerMinute: 16.6
        )
        XCTAssertEqual(mediumStats.formattedDuration, "3m 0s")

        let longStats = SessionStatistics(
            swipeCount: 100,
            deleteCount: 40,
            keepCount: 60,
            sessionDate: Date(),
            durationSeconds: 600,
            averageSwipesPerMinute: 10
        )
        XCTAssertEqual(longStats.formattedDuration, "10m 0s")
    }

    func testSaveAndRetrieveSession() {
        let session = SessionStatistics(
            swipeCount: 50,
            deleteCount: 20,
            keepCount: 30,
            sessionDate: Date(),
            durationSeconds: 300,
            averageSwipesPerMinute: 10
        )

        StatisticsTracker.shared.saveSession(session)

        let allSessions = StatisticsTracker.shared.getAllSessions()
        XCTAssertEqual(allSessions.count, 1)
        XCTAssertEqual(allSessions[0].swipeCount, 50)
    }

    func testGetTotalStatistics() {
        let session1 = SessionStatistics(
            swipeCount: 30,
            deleteCount: 10,
            keepCount: 20,
            sessionDate: Date().addingTimeInterval(-86400),
            durationSeconds: 180,
            averageSwipesPerMinute: 10
        )

        let session2 = SessionStatistics(
            swipeCount: 50,
            deleteCount: 25,
            keepCount: 25,
            sessionDate: Date(),
            durationSeconds: 300,
            averageSwipesPerMinute: 10
        )

        StatisticsTracker.shared.saveSession(session1)
        StatisticsTracker.shared.saveSession(session2)

        let total = StatisticsTracker.shared.getTotalStatistics()

        XCTAssertEqual(total.swipeCount, 80)
        XCTAssertEqual(total.deleteCount, 35)
        XCTAssertEqual(total.keepCount, 45)
        XCTAssertEqual(total.durationSeconds, 480, accuracy: 1)
    }

    func testClearAll() {
        let session = SessionStatistics(
            swipeCount: 50,
            deleteCount: 20,
            keepCount: 30,
            sessionDate: Date(),
            durationSeconds: 300,
            averageSwipesPerMinute: 10
        )

        StatisticsTracker.shared.saveSession(session)
        XCTAssertEqual(StatisticsTracker.shared.getAllSessions().count, 1)

        StatisticsTracker.shared.clearAll()
        XCTAssertEqual(StatisticsTracker.shared.getAllSessions().count, 0)
    }
}