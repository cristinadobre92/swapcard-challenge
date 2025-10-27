import Foundation
import UIKit

public protocol ImageLoading {
    func loadImage(from urlString: String) async -> UIImage?
}

// MARK: - Image Loading Service
public final class ImageLoadingService: ImageLoading {

    private let cache = NSCache<NSString, UIImage>()
    private let session: URLSession

    public init(session: URLSession? = nil) {
        self.session = ImageLoadingService.configure(cache: cache, with: session)
    }

    // Configures cache limits and returns the URLSession to use
    private static func configure(cache: NSCache<NSString, UIImage>, with providedSession: URLSession?) -> URLSession {
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 100 // 100 MB

        if let providedSession {
            return providedSession
        } else {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 30
            return URLSession(configuration: configuration)
        }
    }

    public func loadImage(from urlString: String) async -> UIImage? {
        let cacheKey = NSString(string: urlString)

        // Return cached image if available
        if let cached = cache.object(forKey: cacheKey) {
            return cached
        }

        guard let url = URL(string: urlString) else {
            return nil
        }

        do {
            let (data, _) = try await session.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            cache.setObject(image, forKey: cacheKey)
            return image
        } catch {
            return nil
        }
    }
}
