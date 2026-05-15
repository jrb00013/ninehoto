import Foundation

final class APIEndpointBuilder {
    static let shared = APIEndpointBuilder()
    
    private var baseURL: String = "https://api.ninehoto.com"
    
    private init() {}
    
    func setBaseURL(_ url: String) {
        baseURL = url
    }
    
    func build(path: String, method: HTTPMethod = .get, queryParams: [String: String] = [:]) -> URL? {
        var components = URLComponents(string: baseURL + path)
        
        if !queryParams.isEmpty {
            components?.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        return components?.url
    }
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }
}