import Foundation

final class AppRouter {
    static let shared = AppRouter()
    
    private var routes: [String: RouteHandler] = [:]
    
    typealias RouteHandler = (URL) -> Void
    
    private init() {}
    
    func register(path: String, handler: @escaping RouteHandler) {
        routes[path] = handler
    }
    
    func navigate(to url: URL) {
        let path = url.path
        if let handler = routes[path] {
            handler(url)
        } else {
            Logger.shared.warning("No route registered for: \(path)")
        }
    }
    
    func match(url: URL) -> [String: String]? {
        // Simple URL matching
        var params: [String: String] = [:]
        
        for (path, _) in routes {
            let pathComponents = path.split(separator: "/")
            let urlComponents = url.path.split(separator: "/")
            
            if pathComponents.count == urlComponents.count {
                for (i, component) in pathComponents.enumerated() {
                    if component.hasPrefix(":") {
                        let key = String(component.dropFirst())
                        params[key] = String(urlComponents[i])
                    }
                }
                return params
            }
        }
        
        return nil
    }
}