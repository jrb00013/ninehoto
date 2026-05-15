import Foundation

final class MemoryPressureManager {
    static let shared = MemoryPressureManager()
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    @objc private func handleMemoryWarning() {
        Logger.shared.warning("Memory pressure warning received")
        
        ImageCacheManager.shared.clearMemoryCache()
        ThumbnailCache.shared.clearCache()
        
        NotificationCenter.default.post(name: .memoryPressureWarning, object: nil)
    }
    
    var availableMemory: UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            let used = UInt64(info.resident_size)
            let total = ProcessInfo.processInfo.physicalMemory
            return total - used
        }
        
        return 0
    }
    
    var usedMemory: UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            return UInt64(info.resident_size)
        }
        
        return 0
    }
    
    var memoryUsagePercentage: Double {
        let used = Double(usedMemory)
        let total = Double(ProcessInfo.processInfo.physicalMemory)
        return (used / total) * 100
    }
}

extension Notification.Name {
    static let memoryPressureWarning = Notification.Name("memoryPressureWarning")
}

import UIKit