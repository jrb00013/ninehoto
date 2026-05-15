import XCTest
@testable import Ninehoto

final class DeepLinkHandlerTests: XCTestCase {
    
    var handler: DeepLinkHandler!
    
    override func setUp() {
        super.setUp()
        handler = DeepLinkHandler.shared
    }
    
    func testDeepLinkHome() {
        guard let url = URL(string: "ninehoto://home") else {
            XCTFail("Failed to create URL")
            return
        }
        
        let deepLink = DeepLink(url: url)
        XCTAssertEqual(deepLink, .home)
    }
    
    func testDeepLinkSettings() {
        guard let url = URL(string: "ninehoto://settings") else {
            XCTFail("Failed to create URL")
            return
        }
        
        let deepLink = DeepLink(url: url)
        XCTAssertEqual(deepLink, .settings)
    }
    
    func testDeepLinkStatistics() {
        guard let url = URL(string: "ninehoto://statistics") else {
            XCTFail("Failed to create URL")
            return
        }
        
        let deepLink = DeepLink(url: url)
        XCTAssertEqual(deepLink, .statistics)
    }
    
    func testDeepLinkAbout() {
        guard let url = URL(string: "ninehoto://about") else {
            XCTFail("Failed to create URL")
            return
        }
        
        let deepLink = DeepLink(url: url)
        XCTAssertEqual(deepLink, .about)
    }
    
    func testDeepLinkSession() {
        guard let url = URL(string: "ninehoto://session") else {
            XCTFail("Failed to create URL")
            return
        }
        
        let deepLink = DeepLink(url: url)
        XCTAssertEqual(deepLink, .swipeSession)
    }
    
    func testDeepLinkFinish() {
        guard let url = URL(string: "ninehoto://finish") else {
            XCTFail("Failed to create URL")
            return
        }
        
        let deepLink = DeepLink(url: url)
        XCTAssertEqual(deepLink, .finishConfirmation)
    }
    
    func testDeepLinkUnknown() {
        guard let url = URL(string: "ninehoto://unknown") else {
            XCTFail("Failed to create URL")
            return
        }
        
        let deepLink = DeepLink(url: url)
        XCTAssertEqual(deepLink, .unknown)
    }
    
    func testDeepLinkPath() {
        XCTAssertEqual(DeepLink.home.path, "/")
        XCTAssertEqual(DeepLink.settings.path, "/settings")
        XCTAssertEqual(DeepLink.statistics.path, "/statistics")
        XCTAssertEqual(DeepLink.about.path, "/about")
        XCTAssertEqual(DeepLink.swipeSession.path, "/session")
        XCTAssertEqual(DeepLink.finishConfirmation.path, "/session/finish")
        XCTAssertEqual(DeepLink.unknown.path, "")
    }
    
    func testHandleDeepLink() {
        guard let url = URL(string: "ninehoto://home") else {
            XCTFail("Failed to create URL")
            return
        }
        
        let result = handler.handle(url)
        XCTAssertTrue(result)
    }
}