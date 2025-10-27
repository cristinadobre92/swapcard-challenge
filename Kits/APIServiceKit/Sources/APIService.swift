import Foundation
import SharedModelsKit

// MARK: - APIServicing
public protocol APIServicing: Sendable {
    func fetchUsers(page: Int, results: Int, seed: String?) async throws -> RandomUserResponse
}

// MARK: - Endpoint
private struct Endpoint {
    let baseURL: URL
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]
    let headers: [String: String]
    let body: Data?
    let cachePolicy: URLRequest.CachePolicy
    let timeout: TimeInterval
    
    func makeRequest() throws -> URLRequest {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }
        
        // Build path safely
        let basePath = components.path
        let normalizedBase = basePath.hasSuffix("/") ? String(basePath.dropLast()) : basePath
        let normalizedPath = path.hasPrefix("/") ? path : "/" + path
        components.path = normalizedBase + normalizedPath
        
        // Query
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
        request.httpMethod = method.rawValue
        request.httpBody = body
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        return request
    }
}

// MARK: - APIService
public final class APIService: APIServicing {
    private let configuration: APIServiceConfiguration
    
    public init(configuration: APIServiceConfiguration) {
        self.configuration = configuration
    }
    
    // MARK: - Internal generic request
    @discardableResult
    internal func request<T: Decodable>(
        _ type: T.Type,
        path: String,
        method: HTTPMethod = .GET,
        urlParameters: [String: String]? = nil,
        headers: [String: String]? = nil,
        body: Data? = nil
    ) async throws -> T {
        var mergedHeaders = configuration.defaultHeaders
        if let headers {
            for (k, v) in headers { mergedHeaders[k] = v }
        }
        
        // Map urlParameters to query items
        let queryItems = (urlParameters ?? [:]).map { URLQueryItem(name: $0.key, value: $0.value) }
        
        let endpoint = Endpoint(
            baseURL: configuration.baseURL,
            path: path,
            method: method,
            queryItems: queryItems,
            headers: mergedHeaders,
            body: body,
            cachePolicy: configuration.defaultCachePolicy,
            timeout: configuration.requestTimeout
        )
        
        let request = try endpoint.makeRequest()
        
        do {
            let (data, response) = try await configuration.session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.networkError(URLError(.badServerResponse))
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            
            guard !data.isEmpty else {
                throw NetworkError.noData
            }
            
            do {
                return try configuration.decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }
        } catch {
            if let netErr = error as? NetworkError {
                throw netErr
            } else {
                throw NetworkError.networkError(error)
            }
        }
    }
    
    // MARK: - Fetch Users
    public func fetchUsers(page: Int, results: Int = 25, seed: String? = nil) async throws -> RandomUserResponse {
        var params: [String: String] = [
            "results": "\(results)",
            "page": "\(page)"
        ]
        if let seed = seed {
            params["seed"] = seed
        }
        
        return try await request(
            RandomUserResponse.self,
            path: "/api/",
            method: .GET,
            urlParameters: params,
            headers: nil,
            body: nil
        )
    }
}
