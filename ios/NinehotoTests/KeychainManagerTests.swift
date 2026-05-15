import XCTest
@testable import Ninehoto

final class KeychainManagerTests: XCTestCase {
    
    var keychain: KeychainManager!
    
    override func setUp() {
        super.setUp()
        keychain = KeychainManager.shared
    }
    
    override func tearDown() {
        _ = keychain.delete(forKey: "test_key")
        _ = keychain.delete(forKey: "string_key")
        _ = keychain.delete(forKey: "codable_key")
        super.tearDown()
    }
    
    func testSaveAndLoadData() {
        let testData = "test data".data(using: .utf8)!
        
        let saveResult = keychain.save(testData, forKey: "test_key")
        XCTAssertTrue(saveResult)
        
        let loadedData = keychain.load(forKey: "test_key")
        XCTAssertEqual(loadedData, testData)
    }
    
    func testLoadNonExistent() {
        let loadedData = keychain.load(forKey: "non_existent_key")
        XCTAssertNil(loadedData)
    }
    
    func testDelete() {
        let testData = "delete test".data(using: .utf8)!
        _ = keychain.save(testData, forKey: "test_key")
        
        let deleteResult = keychain.delete(forKey: "test_key")
        XCTAssertTrue(deleteResult)
        
        let loadedData = keychain.load(forKey: "test_key")
        XCTAssertNil(loadedData)
    }
    
    func testSaveAndLoadString() {
        let testString = "Hello, Keychain!"
        
        let saveResult = keychain.saveString(testString, forKey: "string_key")
        XCTAssertTrue(saveResult)
        
        let loadedString = keychain.loadString(forKey: "string_key")
        XCTAssertEqual(loadedString, testString)
    }
    
    func testSaveCodable() {
        struct TestStruct: Codable {
            let name: String
            let value: Int
        }
        
        let testStruct = TestStruct(name: "test", value: 42)
        
        let saveResult = keychain.saveCodable(testStruct, forKey: "codable_key")
        XCTAssertTrue(saveResult)
        
        let loadedStruct: TestStruct? = keychain.loadCodable(forKey: "codable_key", type: TestStruct.self)
        XCTAssertNotNil(loadedStruct)
        XCTAssertEqual(loadedStruct?.name, "test")
        XCTAssertEqual(loadedStruct?.value, 42)
    }
    
    func testUpdateValue() {
        let key = "update_test"
        
        _ = keychain.saveString("first", forKey: key)
        let first = keychain.loadString(forKey: key)
        XCTAssertEqual(first, "first")
        
        _ = keychain.saveString("second", forKey: key)
        let second = keychain.loadString(forKey: key)
        XCTAssertEqual(second, "second")
    }
}

final class TokenStorageTests: XCTestCase {
    
    var keychain: KeychainManager!
    
    override func setUp() {
        super.setUp()
        keychain = KeychainManager.shared
        keychain.clearTokens()
    }
    
    override func tearDown() {
        keychain.clearTokens()
        super.tearDown()
    }
    
    func testSaveAuthToken() {
        keychain.authToken = "test_token_123"
        XCTAssertEqual(keychain.authToken, "test_token_123")
    }
    
    func testSaveRefreshToken() {
        keychain.refreshToken = "refresh_token_456"
        XCTAssertEqual(keychain.refreshToken, "refresh_token_456")
    }
    
    func testClearTokens() {
        keychain.authToken = "token1"
        keychain.refreshToken = "token2"
        
        keychain.clearTokens()
        
        XCTAssertNil(keychain.authToken)
        XCTAssertNil(keychain.refreshToken)
    }
    
    func testNilAuthToken() {
        keychain.authToken = "token"
        keychain.authToken = nil
        
        XCTAssertNil(keychain.authToken)
    }
    
    func testNilRefreshToken() {
        keychain.refreshToken = "token"
        keychain.refreshToken = nil
        
        XCTAssertNil(keychain.refreshToken)
    }
}