import Foundation

struct AppMetric {
    let name: String
    let value: Double
    let timestamp: Date
    let tags: [String: String]
}

final class MetricsCollector {
    static let shared = MetricsCollector()
    
    private var metrics: [AppMetric] = []
    private let queue = DispatchQueue(label: "com.ninehoto.metrics")
    
    private init() {}
    
    func record(_ name: String, value: Double, tags: [String: String] = [:]) {
        queue.async { [weak self] in
            let metric = AppMetric(name: name, value: value, timestamp: Date(), tags: tags)
            self?.metrics.append(metric)
        }
    }
    
    func getMetrics(for name: String) -> [AppMetric] {
        var result: [AppMetric] = []
        queue.sync {
            result = metrics.filter { $0.name == name }
        }
        return result
    }
    
    func getAllMetrics() -> [AppMetric] {
        var result: [AppMetric] = []
        queue.sync {
            result = metrics
        }
        return result
    }
    
    func clearMetrics() {
        queue.async { [weak self] in
            self?.metrics.removeAll()
        }
    }
    
    func average(for name: String) -> Double {
        let filtered = getMetrics(for: name)
        guard !filtered.isEmpty else { return 0 }
        return filtered.reduce(0) { $0 + $1.value } / Double(filtered.count)
    }
}