import Foundation
import os.log

final class PerformanceMonitor {
    static let shared = PerformanceMonitor()

    private var measurements: [String: [TimeInterval]] = [:]
    private let queue = DispatchQueue(label: "com.ninehoto.performance", qos: .utility)

    private init() {}

    func measure(_ block: () -> Void, label: String) {
        let start = CFAbsoluteTimeGetCurrent()
        block()
        let end = CFAbsoluteTimeGetCurrent()
        recordMeasurement(label: label, duration: end - start)
    }

    func measureAsync(_ block: () async -> Void, label: String) async {
        let start = CFAbsoluteTimeGetCurrent()
        await block()
        let end = CFAbsoluteTimeGetCurrent()
        recordMeasurement(label: label, duration: end - start)
    }

    private func recordMeasurement(label: String, duration: TimeInterval) {
        queue.async { [weak self] in
            guard let self = self else { return }
            if self.measurements[label] == nil {
                self.measurements[label] = []
            }
            self.measurements[label]?.append(duration * 1000) // Convert to ms

            if FeatureFlags.shared.isPerformanceMetricsEnabled {
                Logger.shared.debug("[\(label)] \(String(format: "%.2f", duration * 1000))ms")
            }
        }
    }

    func getStatistics(for label: String) -> PerformanceStats? {
        var result: PerformanceStats?
        queue.sync {
            guard let measurements = measurements[label], !measurements.isEmpty else {
                return
            }

            let sorted = measurements.sorted()
            let count = measurements.count
            let sum = measurements.reduce(0, +)
            let avg = sum / Double(count)
            let min = sorted.first ?? 0
            let max = sorted.last ?? 0
            let median = sorted[count / 2]

            result = PerformanceStats(
                label: label,
                count: count,
                averageMs: avg,
                minMs: min,
                maxMs: max,
                medianMs: median,
                totalMs: sum
            )
        }
        return result
    }

    func getAllStatistics() -> [PerformanceStats] {
        var results: [PerformanceStats] = []
        queue.sync {
            for label in measurements.keys {
                if let stats = getStatistics(for: label) {
                    results.append(stats)
                }
            }
        }
        return results.sorted { $0.averageMs > $1.averageMs }
    }

    func clear() {
        queue.async { [weak self] in
            self?.measurements.removeAll()
        }
    }

    func printReport() {
        let stats = getAllStatistics()
        print("=== Performance Report ===")
        for stat in stats {
            print("\(stat.label):")
            print("  Count: \(stat.count)")
            print("  Avg: \(String(format: "%.2f", stat.averageMs))ms")
            print("  Min: \(String(format: "%.2f", stat.minMs))ms")
            print("  Max: \(String(format: "%.2f", stat.maxMs))ms")
            print("  Median: \(String(format: "%.2f", stat.medianMs))ms")
            print("")
        }
    }
}

struct PerformanceStats {
    let label: String
    let count: Int
    let averageMs: Double
    let minMs: Double
    let maxMs: Double
    let medianMs: Double
    let totalMs: Double

    var formatted: String {
        """
        \(label):
          Count: \(count)
          Avg: \(String(format: "%.2f", averageMs))ms
          Min: \(String(format: "%.2f", minMs))ms
          Max: \(String(format: "%.2f", maxMs))ms
          Median: \(String(format: "%.2f", medianMs))ms
        """
    }
}