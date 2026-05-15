import XCTest
import UIKit
@testable import Ninehoto

final class ImageProcessorPerformanceTests: XCTestCase {
    
    var imageProcessor: ImageProcessor!
    var testImage: UIImage!
    
    override func setUp() {
        super.setUp()
        imageProcessor = ImageProcessor.shared
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1000, height: 1000), false, 1.0)
        UIColor.red.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 1000, height: 1000))
        testImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func testResizeImagePerformance() {
        measure {
            _ = imageProcessor.resizeImage(testImage, to: CGSize(width: 100, height: 100))
        }
    }
    
    func testCompressImagePerformance() {
        measure {
            _ = imageProcessor.compressImage(testImage, quality: 0.8)
        }
    }
    
    func testGetMetadataPerformance() {
        measure {
            _ = imageProcessor.getImageMetadata(testImage)
        }
    }
    
    func testRotateImagePerformance() {
        measure {
            _ = imageProcessor.rotateImage(testImage, degrees: 90)
        }
    }
}

final class NetworkMonitorTests: XCTestCase {
    
    var networkMonitor: NetworkMonitor!
    
    override func setUp() {
        super.setUp()
        networkMonitor = NetworkMonitor.shared
    }
    
    func testStartMonitoring() {
        networkMonitor.startMonitoring()
        XCTAssertNotNil(networkMonitor)
    }
    
    func testStopMonitoring() {
        networkMonitor.startMonitoring()
        networkMonitor.stopMonitoring()
        XCTAssertNotNil(networkMonitor)
    }
    
    func testConnectionTypeIsUnknownInitially() {
        let type = networkMonitor.connectionType
        XCTAssertEqual(type, .unknown)
    }
    
    func testIsConnectedProperty() {
        let isConnected = networkMonitor.isConnected
        XCTAssertNotNil(isConnected)
    }
    
    func testIsOnWiFiProperty() {
        let isWiFi = networkMonitor.isOnWiFi
        XCTAssertFalse(isWiFi)
    }
    
    func testIsOnCellularProperty() {
        let isCellular = networkMonitor.isOnCellular
        XCTAssertFalse(isCellular)
    }
}