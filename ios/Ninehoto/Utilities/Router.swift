import Foundation

struct Route: Equatable {
    let path: String
    let params: [String: String]
    let queryItems: [URLQueryItem]
}

final class Router {
    static let shared = Router()
    
    private var routes: [String: (Route) -> Void] = [:]
    
    private init() {}
    
    func register(_ path: String, handler: @escaping (Route) -> Void) {
        routes[path] = handler
    }
    
    func navigate(to path: String, params: [String: String] = [:], queryItems: [URLQueryItem] = []) {
        let route = Route(path: path, params: params, queryItems: queryItems)
        
        if let handler = routes[path] {
            handler(route)
        } else {
            Logger.shared.warning("No route registered for: \(path)")
        }
    }
    
    func match(_ url: URL) -> Route? {
        guard let path = url.path.removingPercentEncoding else { return nil }
        
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        
        return Route(path: path, params: [:], queryItems: queryItems)
    }
}