import Foundation

final class AppHealthMonitor {
    static let shared = AppHealthMonitor()
    
    private var checks: [HealthCheck] = []
    
    private init() {
        registerDefaultChecks()
    }
    
    struct HealthCheck {
        let name: String
        let run: () -> HealthStatus
    }
    
    enum HealthStatus {
        case healthy
        case degraded
        case unhealthy
    }
    
    private func registerDefaultChecks() {
        register(HealthCheck(name: "Memory") { 
            let usage = MemoryPressureManager.shared.memoryUsagePercentage
            if usage < 70 { return .healthy }
            if usage < 90 { return .degraded }
            return .unhealthy
        })
        
        register(HealthCheck(name: "Cache") {
            let cacheSize = CacheManager.shared.diskCacheSize
            if cacheSize < 50_000_000 { return .healthy }
            return .degraded
        })
    }
    
    func register(_ check: HealthCheck) {
        checks.append(check)
    }
    
    func runAllChecks() -> [String: HealthStatus] {
        var results: [String: HealthStatus] = [:]
        for check in checks {
            results[check.name] = check.run()
        }
        return results
    }
    
    var overallHealth: HealthStatus {
        let results = runAllChecks()
        if results.values.contains(.unhealthy) { return .unhealthy }
        if results.values.contains(.degraded) { return .degraded }
        return .healthy
    }
}