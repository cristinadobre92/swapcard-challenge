import UIKit
import APIServiceKit
import BookmarksKit
import DesignKit

class AppCoordinator: Coordinator {
    var tabBarCoordinator: TabBarCoordinator!

    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        // Create dependencies
        let deps = makeDependencies()
        
        // Inject into the TabBarCoordinator
        tabBarCoordinator = TabBarCoordinator(
            bookmarkManager: deps.bookmarkManager,
            imageLoader: deps.imageLoader,
            apiService: deps.apiService
        )
        
        window.rootViewController = tabBarCoordinator.tabBarController
        window.makeKeyAndVisible()
        
        tabBarCoordinator.start()
    }
}

private extension AppCoordinator {
    struct Dependencies {
        let bookmarkManager: BookmarkManaging
        let apiService: APIServicing
        let imageLoader: ImageLoading
    }
    
    func makeDependencies() -> Dependencies {
        let bookmarkManager: BookmarkManaging = BookmarkManager()
        let apiConfig = APIServiceConfiguration.defaultConfig()
        let apiService: APIServicing = APIService(configuration: apiConfig)
        let imageLoader: ImageLoading = ImageLoadingService()
        
        return Dependencies(
            bookmarkManager: bookmarkManager,
            apiService: apiService,
            imageLoader: imageLoader
        )
    }
}
