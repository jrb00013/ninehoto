import Foundation

struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let error: APIError?
}

struct APIError: Error, Decodable {
    let code: String
    let message: String
}

final class APIRequestBuilder {
    static let shared = APIRequestBuilder()
    
    private init() {}
    
    func build<T: Decodable>(url: URL, method: APIEndpointBuilder.HTTPMethod, body: Data? = nil) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError(code: "invalid_response", message: "Invalid response")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError(code: "http_error", message: "HTTP \(httpResponse.statusCode)")
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}