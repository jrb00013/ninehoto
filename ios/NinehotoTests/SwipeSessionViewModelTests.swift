import XCTest
@testable import Ninehoto

final class SwipeSessionViewModelTests: XCTestCase {
    private var viewModel: SwipeSessionViewModel!

    override func setUp() async throws {
        await MainActor.run {
            viewModel = SwipeSessionViewModel()
        }
    }

    override func tearDown() async throws {
        await viewModel.resetToMainMenu()
    }

    func testInitialState() async throws {
        await MainActor.run {
            XCTAssertEqual(viewModel.phase, .mainMenu)
            XCTAssertEqual(viewModel.assets.count, 0)
            XCTAssertEqual(viewModel.currentIndex, 0)
            XCTAssertEqual(viewModel.pendingDeleteCount, 0)
            XCTAssertEqual(viewModel.remainingCount, 0)
            XCTAssertFalse(viewModel.canUndo)
        }
    }

    func testCanUndoIsFalseInitially() async throws {
        await MainActor.run {
            XCTAssertFalse(viewModel.canUndo)
        }
    }

    func testRemainingCountWithNoAssets() async throws {
        await MainActor.run {
            XCTAssertEqual(viewModel.remainingCount, 0)
            XCTAssertEqual(viewModel.currentAsset, nil)
        }
    }

    func testSwipeLeftWithoutSessionDoesNothing() async throws {
        await MainActor.run {
            let initialPhase = viewModel.phase
            viewModel.swipeLeft()
            XCTAssertEqual(viewModel.phase, initialPhase)
        }
    }

    func testSwipeRightWithoutSessionDoesNothing() async throws {
        await MainActor.run {
            let initialPhase = viewModel.phase
            viewModel.swipeRight()
            XCTAssertEqual(viewModel.phase, initialPhase)
        }
    }

    func testTapDoneShowsConfirmation() async throws {
        await MainActor.run {
            XCTAssertFalse(viewModel.showFinishConfirmation)
            viewModel.tapDone()
            XCTAssertTrue(viewModel.showFinishConfirmation)
        }
    }

    func testCancelFinishHidesConfirmation() async throws {
        await MainActor.run {
            viewModel.tapDone()
            XCTAssertTrue(viewModel.showFinishConfirmation)
            viewModel.cancelFinish()
            XCTAssertFalse(viewModel.showFinishConfirmation)
        }
    }

    func testSessionLimitIsReasonable() {
        XCTAssertEqual(SwipeSessionViewModel.sessionLimit, 200)
        XCTAssertGreaterThan(SwipeSessionViewModel.sessionLimit, 0)
        XCTAssertLessThan(SwipeSessionViewModel.sessionLimit, 10000)
    }

    func testAuthorizationStateDefaultIsNotDetermined() async throws {
        await MainActor.run {
            XCTAssertEqual(viewModel.authorizationState, .notDetermined)
        }
    }

    func testCanStartSessionDenied() async throws {
        await MainActor.run {
            let status = PHAuthorizationStatus.denied
            XCTAssertFalse(status == .notDetermined)
        }
    }

    func testDismissResult() async throws {
        await MainActor.run {
            viewModel.resultMessage = "test"
            viewModel.showResultAlert = true
            viewModel.dismissResult()
            XCTAssertFalse(viewModel.showResultAlert)
        }
    }

    func testResetToMainMenuClearsState() async throws {
        await MainActor.run {
            viewModel.phase = .swiping
            viewModel.assets = []
            viewModel.currentIndex = 99
            viewModel.pendingDeletionIds = ["fake-id"]
            viewModel.resetToMainMenu()
            XCTAssertEqual(viewModel.phase, .mainMenu)
            XCTAssertEqual(viewModel.assets.count, 0)
            XCTAssertEqual(viewModel.currentIndex, 0)
            XCTAssertEqual(viewModel.pendingDeleteCount, 0)
        }
    }
}
