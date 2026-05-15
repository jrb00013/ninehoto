import Foundation

final class DeviceIdentifier {
    static let shared = DeviceIdentifier()
    
    private init() {}
    
    var uniqueId: String {
        if let stored = UserDefaults.standard.string(forKey: "device_unique_id") {
            return stored
        }
        
        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: "device_unique_id")
        return newId
    }
    
    var vendorId: String {
        UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
    }
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}

import UIKit