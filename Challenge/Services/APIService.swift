import Foundation

// MARK: - HTTPMethod
enum HTTPMethod: String {
    case GET, POST, PUT, PATCH, DELETE
}

// MARK: - NetworkError
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(Error)
    case httpError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)"
        }
    }
}

// MARK: - APIServicing
protocol APIServicing {
    func fetchUsers(page: Int, results: Int, seed: String?) async throws -> RandomUserResponse
    
    // Generic request for future scalability
    @discardableResult
    func request<T: Decodable>(
        _ type: T.Type,
        path: String,
        method: HTTPMethod,
        urlParameters: [String: String]?,
        headers: [String: String]?,
        body: Data?
    ) async throws -> T
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
final class APIService: APIServicing {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let defaultHeaders: [String: String]
    private let defaultCachePolicy: URLRequest.CachePolicy
    private let requestTimeout: TimeInterval
    
    init(
        baseURL: URL = URL(string: "https://randomuser.me")!,
        session: URLSession = {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 30
            configuration.timeoutIntervalForResource = 60
            configuration.requestCachePolicy = .useProtocolCachePolicy
            return URLSession(configuration: configuration)
        }(),
        decoder: JSONDecoder = JSONDecoder(),
        defaultHeaders: [String: String] = [
            "Accept": "application/json",
            "Accept-Encoding": "gzip, deflate, br",
            "User-Agent": "RandomUsersApp/1.0 (iOS)"
        ],
        defaultCachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        requestTimeout: TimeInterval = 30
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
        self.defaultHeaders = defaultHeaders
        self.defaultCachePolicy = defaultCachePolicy
        self.requestTimeout = requestTimeout
    }
    
    // MARK: - Public generic request
    @discardableResult
    func request<T: Decodable>(
        _ type: T.Type,
        path: String,
        method: HTTPMethod = .GET,
        urlParameters: [String: String]? = nil,
        headers: [String: String]? = nil,
        body: Data? = nil
    ) async throws -> T {
        // Merge headers (endpoint overrides defaults)
        var mergedHeaders = defaultHeaders
        if let headers {
            for (k, v) in headers { mergedHeaders[k] = v }
        }
        
        // Map urlParameters to query items
        let queryItems = (urlParameters ?? [:]).map { URLQueryItem(name: $0.key, value: $0.value) }
        
        let endpoint = Endpoint(
            baseURL: baseURL,
            path: path,
            method: method,
            queryItems: queryItems,
            headers: mergedHeaders,
            body: body,
            cachePolicy: defaultCachePolicy,
            timeout: requestTimeout
        )
        
        let request = try endpoint.makeRequest()
        
        do {
            let (data, response) = try await session.data(for: request)
            
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
                return try decoder.decode(T.self, from: data)
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
    func fetchUsers(page: Int, results: Int = 25, seed: String? = nil) async throws -> RandomUserResponse {
        var params: [String: String] = [
            "results": "\(results)",
            "page": "\(page)"
        ]
        if let seed = seed {
            params["seed"] = seed
        }
        
        // randomuser path
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
