import UIKit

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
        
        // Inject into the TabBarCoordinator
        tabBarCoordinator = TabBarCoordinator(bookmarkManager: bookmarkManager, apiService: apiService)
        
        window.rootViewController = tabBarCoordinator.tabBarController
        window.makeKeyAndVisible()
        
        tabBarCoordinator.start()
    }
}

extension AppCoordinator {
    func assembleDependencyInjectionContainer() {
    }
}

