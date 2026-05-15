import Foundation

final class CrashReporter {
    static let shared = CrashReporter()
    
    private init() {}
    
    func logCrash(_ error: Error, context: String = "") {
        let crashLog = """
        Crash Report
        =============
        Date: \(Date())
        Context: \(context)
        
        Error: \(error.localizedDescription)
        Stack Trace: \(Thread.callStackSymbols)
        """
        
        Logger.shared.error("CRASH: \(crashLog)")
        saveCrashLog(crashLog)
    }
    
    private func saveCrashLog(_ log: String) {
        let fileName = "crash_\(Date().timeIntervalSince1970).log"
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        try? log.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    
    func getCrashLogs() -> [URL] {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        guard let files = try? FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil) else {
            return []
        }
        
        return files.filter { $0.pathExtension == "log" && $0.lastPathComponent.hasPrefix("crash_") }
    }
    
    func clearCrashLogs() {
        let logs = getCrashLogs()
        for log in logs {
            try? FileManager.default.removeItem(at: log)
        }
    }
}