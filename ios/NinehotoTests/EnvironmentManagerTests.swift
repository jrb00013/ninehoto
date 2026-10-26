import XCTest
@testable import Ninehoto

final class EnvironmentManagerTests: XCTestCase {
    
    var envManager: EnvironmentManager!
    
    override func setUp() {
        super.setUp()
        envManager = EnvironmentManager.shared
    }
    
    func testDefaultEnvironment() {
        let env = envManager.current
        #if DEBUG
        XCTAssertEqual(env, .development)
        #else
        XCTAssertEqual(env, .production)
        #endif
    }
    
    func testSetEnvironment() {
        envManager.current = .staging
        XCTAssertEqual(envManager.current, .staging)
        
        envManager.current = .production
        XCTAssertEqual(envManager.current, .production)
        
        envManager.current = .development
        XCTAssertEqual(envManager.current, .development)
    }
    
    func testIsDevelopment() {
        envManager.current = .development
        XCTAssertTrue(envManager.isDevelopment)
        XCTAssertFalse(envManager.isStaging)
        XCTAssertFalse(envManager.isProduction)
    }
    
    func testIsStaging() {
        envManager.current = .staging
        XCTAssertFalse(envManager.isDevelopment)
        XCTAssertTrue(envManager.isStaging)
        XCTAssertFalse(envManager.isProduction)
    }
    
    func testIsProduction() {
        envManager.current = .production
        XCTAssertFalse(envManager.isDevelopment)
        XCTAssertFalse(envManager.isStaging)
        XCTAssertTrue(envManager.isProduction)
    }
    
    func testEnvironmentBaseURL() {
        let devURL = AppEnvironment.development.baseURL
        XCTAssertTrue(devURL.contains("dev"))
        
        let stagingURL = AppEnvironment.staging.baseURL
        XCTAssertTrue(stagingURL.contains("staging"))
        
        let prodURL = AppEnvironment.production.baseURL
        XCTAssertTrue(prodURL.contains("ninehoto.com"))
    }
    
    func testEnvironmentIsDebugEnabled() {
        XCTAssertTrue(AppEnvironment.development.isDebugEnabled)
        XCTAssertTrue(AppEnvironment.staging.isDebugEnabled)
        XCTAssertFalse(AppEnvironment.production.isDebugEnabled)
    }
    
    func testEnvironmentSupportsAnalytics() {
        XCTAssertFalse(AppEnvironment.development.supportsAnalytics)
        XCTAssertFalse(AppEnvironment.staging.supportsAnalytics)
        XCTAssertTrue(AppEnvironment.production.supportsAnalytics)
    }
    
    func testEnvironmentLogLevel() {
        XCTAssertEqual(AppEnvironment.development.logLevel, .debug)
        XCTAssertEqual(AppEnvironment.staging.logLevel, .info)
        XCTAssertEqual(AppEnvironment.production.logLevel, .warning)
    }
    
    func testApiBaseURL() {
        envManager.current = .development
        XCTAssertEqual(envManager.apiBaseURL, AppEnvironment.development.baseURL)
        
        envManager.current = .staging
        XCTAssertEqual(envManager.apiBaseURL, AppEnvironment.staging.baseURL)
        
        envManager.current = .production
        XCTAssertEqual(envManager.apiBaseURL, AppEnvironment.production.baseURL)
    }
}