import XCTest
@testable import Ninehoto

final class SystemMonitorTests: XCTestCase {
    
    var systemMonitor: SystemMonitor!
    
    override func setUp() {
        super.setUp()
        systemMonitor = SystemMonitor.shared
    }
    
    func testGetDeviceInfo() {
        let deviceInfo = systemMonitor.getDeviceInfo()
        
        XCTAssertFalse(deviceInfo.model.isEmpty)
        XCTAssertFalse(deviceInfo.name.isEmpty)
        XCTAssertFalse(deviceInfo.systemName.isEmpty)
        XCTAssertFalse(deviceInfo.systemVersion.isEmpty)
    }
    
    func testDeviceInfoFullDescription() {
        let deviceInfo = systemMonitor.getDeviceInfo()
        let description = deviceInfo.fullDescription
        
        XCTAssertFalse(description.isEmpty)
        XCTAssertTrue(description.contains(deviceInfo.name))
    }
    
    func testGetMemoryInfo() {
        let memoryInfo = systemMonitor.getMemoryInfo()
        
        XCTAssertGreaterThan(memoryInfo.total, 0)
        XCTAssertGreaterThan(memoryInfo.available, 0)
        XCTAssertGreaterThanOrEqual(memoryInfo.used, 0)
        XCTAssertGreaterThanOrEqual(memoryInfo.percentage, 0)
        XCTAssertLessThanOrEqual(memoryInfo.percentage, 100)
    }
    
    func testMemoryInfoFormatted() {
        let memoryInfo = systemMonitor.getMemoryInfo()
        
        XCTAssertFalse(memoryInfo.formattedTotal.isEmpty)
        XCTAssertFalse(memoryInfo.formattedAvailable.isEmpty)
        XCTAssertFalse(memoryInfo.formattedUsed.isEmpty)
    }
    
    func testGetStorageInfo() {
        let storageInfo = systemMonitor.getStorageInfo()
        
        XCTAssertGreaterThanOrEqual(storageInfo.total, 0)
        XCTAssertGreaterThanOrEqual(storageInfo.available, 0)
        XCTAssertGreaterThanOrEqual(storageInfo.used, 0)
        XCTAssertGreaterThanOrEqual(storageInfo.percentage, 0)
        XCTAssertLessThanOrEqual(storageInfo.percentage, 100)
    }
    
    func testStorageInfoFormatted() {
        let storageInfo = systemMonitor.getStorageInfo()
        
        XCTAssertFalse(storageInfo.formattedTotal.isEmpty)
        XCTAssertFalse(storageInfo.formattedAvailable.isEmpty)
        XCTAssertFalse(storageInfo.formattedUsed.isEmpty)
    }
    
    func testGetBatteryInfo() {
        let batteryInfo = systemMonitor.getBatteryInfo()
        
        XCTAssertGreaterThanOrEqual(batteryInfo.level, 0)
        XCTAssertLessThanOrEqual(batteryInfo.level, 100)
    }
    
    func testBatteryInfoStateDescription() {
        let batteryInfo = systemMonitor.getBatteryInfo()
        
        XCTAssertFalse(batteryInfo.stateDescription.isEmpty)
    }
    
    func testIsLowMemory() {
        let isLowMemory = systemMonitor.isLowMemory
        
        XCTAssertFalse(isLowMemory) // Should be false in test environment
    }
    
    func testIsLowStorage() {
        let isLowStorage = systemMonitor.isLowStorage
        
        XCTAssertFalse(isLowStorage) // Should be false in test environment
    }
    
    func testLogSystemInfo() {
        // Should not throw
        systemMonitor.logSystemInfo()
    }
}