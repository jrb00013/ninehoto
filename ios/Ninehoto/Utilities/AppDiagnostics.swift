import Foundation

final class AppDiagnostics {
    static let shared = AppDiagnostics()
    
    private init() {}
    
    func generateReport() -> String {
        """
        Ninehoto Diagnostics Report
        ===========================
        
        Version: \(Bundle.main.fullVersion)
        Device: \(SystemMonitor.shared.getDeviceInfo().fullDescription)
        
        Memory:
        - Used: \(SystemMonitor.shared.getMemoryInfo().formattedUsed)
        - Available: \(SystemMonitor.shared.getMemoryInfo().formattedAvailable)
        
        Storage:
        - Used: \(SystemMonitor.shared.getStorageInfo().formattedUsed)
        - Available: \(SystemMonitor.shared.getStorageInfo().formattedAvailable)
        
        Battery: \(SystemMonitor.shared.getBatteryInfo().level)%
        
        Network: \(NetworkMonitor.shared.isConnected ? "Connected" : "Disconnected")
        
        Feature Flags: \(FeatureFlags.shared.isSwipeUndoEnabled ? "On" : "Off")
        
        Recent Logs: \(AppLogger.shared.getLogs().suffix(5).map { $0.message }.joined(separator: "\n"))
        """
    }
    
    func exportReport() -> URL? {
        let report = generateReport()
        let fileName = "diagnostics_\(Date().timeIntervalSince1970).txt"
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        do {
            try report.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            return nil
        }
    }
}