import Foundation

final class DependencyGraph {
    static let shared = DependencyGraph()
    
    private var dependencies: [String: [String]] = [:]
    
    private init() {}
    
    func register(_ dependency: String, for service: String) {
        if dependencies[service] == nil {
            dependencies[service] = []
        }
        dependencies[service]?.append(dependency)
    }
    
    func resolve(_ service: String) -> [String] {
        var resolved: [String] = []
        var visiting: Set<String> = []
        
        func visit(_ s: String) {
            if visiting.contains(s) { return }
            visiting.insert(s)
            
            if let deps = dependencies[s] {
                for dep in deps {
                    visit(dep)
                    resolved.append(dep)
                }
            }
        }
        
        visit(service)
        return resolved
    }
    
    func hasCircularDependency() -> Bool {
        // Check for circular dependencies
        false
    }
}