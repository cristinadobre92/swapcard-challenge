import Foundation

public struct APIServiceConfiguration: Sendable {
    public let baseURL: URL
    public let session: URLSession
    public let decoder: JSONDecoder
    public let defaultHeaders: [String: String]
    public let defaultCachePolicy: URLRequest.CachePolicy
    public let requestTimeout: TimeInterval

    public init(
        baseURL: URL,
        session: URLSession,
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
}

public extension APIServiceConfiguration {
    static func defaultConfig() -> APIServiceConfiguration {
        // Read base URL from Info.plist
        let baseURLString = Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String

        // Fallback for development if missing/invalid
        let fallback = "https://randomuser.me"
        let resolvedBaseURLString = (baseURLString?.isEmpty == false) ? baseURLString! : fallback

        guard let baseURL = URL(string: resolvedBaseURLString) else {
            // As a last resort, crash in debug to surface misconfiguration; in release use fallback
            assertionFailure("Invalid APIBaseURL in Info.plist. Falling back to \(fallback).")
            return defaultConfigWith(baseURL: URL(string: fallback)!)
        }

        return defaultConfigWith(baseURL: baseURL)
    }

    private static func defaultConfigWith(baseURL: URL) -> APIServiceConfiguration {
        let urlConfig = URLSessionConfiguration.default
        urlConfig.timeoutIntervalForRequest = 30
        urlConfig.timeoutIntervalForResource = 60
        urlConfig.requestCachePolicy = .useProtocolCachePolicy

        let session = URLSession(configuration: urlConfig)
        let decoder = JSONDecoder()

        return APIServiceConfiguration(
            baseURL: baseURL,
            session: session,
            decoder: decoder,
            defaultHeaders: [
                "Accept": "application/json",
                "Accept-Encoding": "gzip, deflate, br",
                "User-Agent": "RandomUsersApp/1.0 (iOS)"
            ],
            defaultCachePolicy: .useProtocolCachePolicy,
            requestTimeout: 30
        )
    }
}
