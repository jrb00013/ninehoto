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
        let devURL = Environment.development.baseURL
        XCTAssertTrue(devURL.contains("dev"))
        
        let stagingURL = Environment.staging.baseURL
        XCTAssertTrue(stagingURL.contains("staging"))
        
        let prodURL = Environment.production.baseURL
        XCTAssertTrue(prodURL.contains("ninehoto.com"))
    }
    
    func testEnvironmentIsDebugEnabled() {
        XCTAssertTrue(Environment.development.isDebugEnabled)
        XCTAssertTrue(Environment.staging.isDebugEnabled)
        XCTAssertFalse(Environment.production.isDebugEnabled)
    }
    
    func testEnvironmentSupportsAnalytics() {
        XCTAssertFalse(Environment.development.supportsAnalytics)
        XCTAssertFalse(Environment.staging.supportsAnalytics)
        XCTAssertTrue(Environment.production.supportsAnalytics)
    }
    
    func testEnvironmentLogLevel() {
        XCTAssertEqual(Environment.development.logLevel, .debug)
        XCTAssertEqual(Environment.staging.logLevel, .info)
        XCTAssertEqual(Environment.production.logLevel, .warning)
    }
    
    func testApiBaseURL() {
        envManager.current = .development
        XCTAssertEqual(envManager.apiBaseURL, Environment.development.baseURL)
        
        envManager.current = .staging
        XCTAssertEqual(envManager.apiBaseURL, Environment.staging.baseURL)
        
        envManager.current = .production
        XCTAssertEqual(envManager.apiBaseURL, Environment.production.baseURL)
    }
}