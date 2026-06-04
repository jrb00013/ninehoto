import Foundation

final class AppReporter {
    static let shared = AppReporter()
    
    private init() {}
    
    func reportCrash(_ error: Error, stackTrace: String) {
        let report = CrashReport(
            error: error.localizedDescription,
            stackTrace: stackTrace,
            timestamp: Date(),
            deviceInfo: SystemMonitor.shared.getDeviceInfo().fullDescription
        )
        
        Logger.shared.error("Crash reported: \(report.error)")
    }
}

struct CrashReport: Codable {
    let error: String
    let stackTrace: String
    let timestamp: Date
    let deviceInfo: String
}