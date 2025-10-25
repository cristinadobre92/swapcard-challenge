import Foundation

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
}

// MARK: - APIService
final class APIService: APIServicing {
    private let baseURL = "https://randomuser.me/api/"
    private let session: URLSession
    
    init(session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        return URLSession(configuration: configuration)
    }()) {
        self.session = session
    }
    
    // MARK: - Fetch Users (async/await)
    func fetchUsers(page: Int, results: Int = 25, seed: String? = nil) async throws -> RandomUserResponse {
        var components = URLComponents(string: baseURL)
        
        var queryItems = [
            URLQueryItem(name: "results", value: "\(results)"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        if let seed = seed {
            queryItems.append(URLQueryItem(name: "seed", value: seed))
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
        
        print("🌐 Fetching users from: \(url.absoluteString)")
        
        do {
            let (data, response) = try await session.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            
            guard !data.isEmpty else {
                throw NetworkError.noData
            }
            
            do {
                let randomUserResponse = try JSONDecoder().decode(RandomUserResponse.self, from: data)
                print("✅ Successfully fetched \(randomUserResponse.results.count) users")
                return randomUserResponse
            } catch {
                print("❌ Decoding error: \(error)")
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
}

