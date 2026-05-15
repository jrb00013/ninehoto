import Foundation

final class AppLogger {
    static let shared = AppLogger()
    
    private var logs: [LogEntry] = []
    private let queue = DispatchQueue(label: "com.ninehoto.applogger")
    
    private init() {}
    
    struct LogEntry {
        let level: LogLevel
        let message: String
        let timestamp: Date
        let source: String
    }
    
    enum LogLevel: String {
        case debug, info, warning, error
    }
    
    func log(_ level: LogLevel, message: String, source: String = #function) {
        let entry = LogEntry(level: level, message: message, timestamp: Date(), source: source)
        
        queue.async { [weak self] in
            self?.logs.append(entry)
            
            if self?.logs.count ?? 0 > 1000 {
                self?.logs.removeFirst()
            }
        }
    }
    
    func getLogs() -> [LogEntry] {
        var result: [LogEntry] = []
        queue.sync {
            result = logs
        }
        return result
    }
    
    func clearLogs() {
        queue.async { [weak self] in
            self?.logs.removeAll()
        }
    }
}