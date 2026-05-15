import XCTest
@testable import Ninehoto

final class CacheManagerTests: XCTestCase {
    
    var cacheManager: CacheManager!
    
    override func setUp() {
        super.setUp()
        cacheManager = CacheManager.shared
        cacheManager.clearAll()
    }
    
    override func tearDown() {
        cacheManager.clearAll()
        super.tearDown()
    }
    
    func testSetAndGetValue() {
        let testValue = "test string"
        cacheManager.set(testValue as NSString, forKey: "test")
        
        let result: String? = cacheManager.get(forKey: "test")
        XCTAssertEqual(result, testValue)
    }
    
    func testRemoveValue() {
        cacheManager.set("test" as NSString, forKey: "test")
        cacheManager.remove(forKey: "test")
        
        let result: String? = cacheManager.get(forKey: "test")
        XCTAssertNil(result)
    }
    
    func testClearMemoryCache() {
        cacheManager.set("test1" as NSString, forKey: "key1")
        cacheManager.set("test2" as NSString, forKey: "key2")
        
        cacheManager.clearMemoryCache()
        
        let result1: String? = cacheManager.get(forKey: "key1")
        let result2: String? = cacheManager.get(forKey: "key2")
        
        XCTAssertNil(result1)
        XCTAssertNil(result2)
    }
    
    func testSetToDiskAndGetFromDisk() {
        struct TestStruct: Codable {
            let name: String
            let value: Int
        }
        
        let testStruct = TestStruct(name: "test", value: 42)
        cacheManager.setToDisk(testStruct, forKey: "disk_test")
        
        let result: TestStruct? = cacheManager.getFromDisk(forKey: "disk_test", type: TestStruct.self)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.name, "test")
        XCTAssertEqual(result?.value, 42)
    }
    
    func testRemoveFromDisk() {
        let testValue = "disk test"
        cacheManager.setToDisk(testValue, forKey: "disk_key")
        cacheManager.removeFromDisk(forKey: "disk_key")
        
        let result: String? = cacheManager.getFromDisk(forKey: "disk_key", type: String.self)
        XCTAssertNil(result)
    }
    
    func testClearDiskCache() {
        cacheManager.setToDisk("value1", forKey: "key1")
        cacheManager.setToDisk("value2", forKey: "key2")
        
        cacheManager.clearDiskCache()
        
        let result1: String? = cacheManager.getFromDisk(forKey: "key1", type: String.self)
        let result2: String? = cacheManager.getFromDisk(forKey: "key2", type: String.self)
        
        XCTAssertNil(result1)
        XCTAssertNil(result2)
    }
    
    func testClearAll() {
        cacheManager.set("memory" as NSString, forKey: "memory_key")
        cacheManager.setToDisk("disk", forKey: "disk_key")
        
        cacheManager.clearAll()
        
        let memoryResult: String? = cacheManager.get(forKey: "memory_key")
        let diskResult: String? = cacheManager.getFromDisk(forKey: "disk_key", type: String.self)
        
        XCTAssertNil(memoryResult)
        XCTAssertNil(diskResult)
    }
    
    func testCachedValue() {
        struct TestData: Codable {
            let id: Int
            let name: String
        }
        
        let data = TestData(id: 1, name: "cached")
        cacheManager.cached(data, forKey: "cached_test", ttl: 60)
        
        let retrieved: TestData? = cacheManager.getCached(forKey: "cached_test", type: TestData.self)
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.id, 1)
    }
    
    func testCachedValueExpired() {
        struct TestData: Codable {
            let id: Int
        }
        
        let data = TestData(id: 1)
        cacheManager.cached(data, forKey: "expired_test", ttl: 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let result: TestData? = self.cacheManager.getCached(forKey: "expired_test", type: TestData.self)
            XCTAssertNil(result)
        }
    }
    
    func testDiskCacheSize() {
        cacheManager.setToDisk("test value", forKey: "size_test")
        
        let size = cacheManager.diskCacheSize
        XCTAssertGreaterThan(size, 0)
    }
    
    func testMemoryCacheSize() {
        let size = cacheManager.memoryCacheSize
        XCTAssertGreaterThan(size, 0)
    }
}