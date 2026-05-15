import Foundation
import UIKit

final class SystemMonitor {
    static let shared = SystemMonitor()
    
    private init() {}
    
    struct DeviceInfo {
        let model: String
        let name: String
        let systemName: String
        let systemVersion: String
        let identifier: String
        
        var fullDescription: String {
            "\(name) (\(model)) - \(systemName) \(systemVersion)"
        }
    }
    
    struct MemoryInfo {
        let total: UInt64
        let available: UInt64
        let used: UInt64
        let percentage: Double
        
        var formattedTotal: String { ByteCountFormatter.string(fromByteCount: Int64(total), countStyle: .memory) }
        var formattedAvailable: String { ByteCountFormatter.string(fromByteCount: Int64(available), countStyle: .memory) }
        var formattedUsed: String { ByteCountFormatter.string(fromByteCount: Int64(used), countStyle: .memory) }
    }
    
    struct StorageInfo {
        let total: UInt64
        let available: UInt64
        let used: UInt64
        let percentage: Double
        
        var formattedTotal: String { ByteCountFormatter.string(fromByteCount: Int64(total), countStyle: .file) }
        var formattedAvailable: String { ByteCountFormatter.string(fromByteCount: Int64(available), countStyle: .file) }
        var formattedUsed: String { ByteCountFormatter.string(fromByteCount: Int64(used), countStyle: .file) }
    }
    
    struct BatteryInfo {
        let level: Int
        let state: UIDevice.BatteryState
        let isLowPowerMode: Bool
        
        var isCharging: Bool {
            state == .charging || state == .full
        }
        
        var stateDescription: String {
            switch state {
            case .unknown: return "Unknown"
            case .unplugged: return "Unplugged"
            case .charging: return "Charging"
            case .full: return "Full"
            @unknown default: return "Unknown"
            }
        }
    }
    
    func getDeviceInfo() -> DeviceInfo {
        DeviceInfo(
            model: UIDevice.current.model,
            name: UIDevice.current.name,
            systemName: UIDevice.current.systemName,
            systemVersion: UIDevice.current.systemVersion,
            identifier: UIDevice.current.identifierForVendor?.uuidString ?? ""
        )
    }
    
    func getMemoryInfo() -> MemoryInfo {
        var taskInfo = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        
        let used: UInt64
        if result == KERN_SUCCESS {
            used = UInt64(taskInfo.phys_footprint)
        } else {
            used = 0
        }
        
        let total = ProcessInfo.processInfo.physicalMemory
        let available = total - used
        let percentage = Double(used) / Double(total) * 100
        
        return MemoryInfo(total: total, available: available, used: used, percentage: percentage)
    }
    
    func getStorageInfo() -> StorageInfo {
        do {
            let homeURL = URL(fileURLWithPath: NSHomeDirectory())
            let values = try homeURL.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey])
            
            let total = UInt64(values.volumeTotalCapacity ?? 0)
            let available = UInt64(values.volumeAvailableCapacity ?? 0)
            let used = total - available
            let percentage = Double(used) / Double(total) * 100
            
            return StorageInfo(total: total, available: available, used: used, percentage: percentage)
        } catch {
            return StorageInfo(total: 0, available: 0, used: 0, percentage: 0)
        }
    }
    
    func getBatteryInfo() -> BatteryInfo {
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        return BatteryInfo(
            level: Int(UIDevice.current.batteryLevel * 100),
            state: UIDevice.current.batteryState,
            isLowPowerMode: ProcessInfo.processInfo.isLowPowerModeEnabled
        )
    }
    
    var isLowMemory: Bool {
        getMemoryInfo().percentage > 90
    }
    
    var isLowStorage: Bool {
        getStorageInfo().percentage > 90
    }
    
    func logSystemInfo() {
        let device = getDeviceInfo()
        let memory = getMemoryInfo()
        let storage = getStorageInfo()
        let battery = getBatteryInfo()
        
        Logger.shared.info("=== System Info ===")
        Logger.shared.info("Device: \(device.fullDescription)")
        Logger.shared.info("Memory: \(memory.formattedUsed) / \(memory.formattedTotal) (\(String(format: "%.1f", memory.percentage))%)")
        Logger.shared.info("Storage: \(storage.formattedUsed) / \(storage.formattedTotal) (\(String(format: "%.1f", storage.percentage))%)")
        Logger.shared.info("Battery: \(battery.level)% (\(battery.stateDescription))")
        if battery.isLowPowerMode {
            Logger.shared.info("Low Power Mode: Enabled")
        }
    }
}

extension ProcessInfo {
    var isLowPowerModeEnabled: Bool {
        processInfo.isLowPowerModeEnabled
    }
}