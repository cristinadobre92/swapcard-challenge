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
        let bookmarkManager: BookmarkManaging = BookmarkManager()
        let apiService: APIServicing = APIService()
        let imageLoader: ImageLoading = ImageLoadingService()
        
        // Inject into the TabBarCoordinator
        tabBarCoordinator = TabBarCoordinator(
            bookmarkManager: bookmarkManager,
            imageLoader: imageLoader,
            apiService: apiService
        )
        
        window.rootViewController = tabBarCoordinator.tabBarController
        window.makeKeyAndVisible()
        
        tabBarCoordinator.start()
    }
}

