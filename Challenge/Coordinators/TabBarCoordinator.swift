import UIKit
import APIServiceKit

class TabBarCoordinator: NSObject, Coordinator {
    var navigationController: UINavigationController
    
    private(set) var tabBarController: UITabBarController
    private var usersListCoordinator: UsersListCoordinator?
    private var bookmarksCoordinator: BookmarksCoordinator?
    
    private let bookmarkManager: BookmarkManaging
    private let apiService: APIServicing
    
    init(bookmarkManager: BookmarkManaging, apiService: APIServicing) {
        self.navigationController = UINavigationController()
        self.tabBarController = UITabBarController()
        self.bookmarkManager = bookmarkManager
        self.apiService = apiService
    }
    
    func start() {
        setupTabBar()
        setupCoordinators()
    }
    
    private func setupTabBar() {
        // Configure tab bar appearance
        tabBarController.tabBar.tintColor = .systemBlue
        tabBarController.tabBar.unselectedItemTintColor = .systemGray
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            
            tabBarController.tabBar.standardAppearance = appearance
            tabBarController.tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func setupCoordinators() {
        // Users List Coordinator
        let usersListNavController = UINavigationController()
        usersListCoordinator = UsersListCoordinator(
            navigationController: usersListNavController,
            bookmarkManager: bookmarkManager,
            apiService: apiService
        )

        usersListNavController.tabBarItem = UITabBarItem(
            title: "Users",
            image: UIImage(systemName: "person.2"),
            selectedImage: UIImage(systemName: "person.2.fill")
        )
        
        // Bookmarks Coordinator
        let bookmarksNavController = UINavigationController()
        bookmarksCoordinator = BookmarksCoordinator(
            navigationController: bookmarksNavController,
            bookmarkManager: bookmarkManager
        )
        
        bookmarksNavController.tabBarItem = UITabBarItem(
            title: "Bookmarks",
            image: UIImage(systemName: "bookmark"),
            selectedImage: UIImage(systemName: "bookmark.fill")
        )
        
        // Set up tab bar view controllers
        tabBarController.viewControllers = [usersListNavController, bookmarksNavController]
        
        // Start child coordinators
        usersListCoordinator?.start()
        bookmarksCoordinator?.start()
        
        // Setup bookmark badge observer
        setupBookmarkBadgeObserver()
        updateBookmarkBadge()
    }
    
    private func setupBookmarkBadgeObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(bookmarkDidChange),
            name: BookmarkManager.bookmarkDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func bookmarkDidChange(_ notification: Notification) {
        updateBookmarkBadge()
    }
    
    private func updateBookmarkBadge() {
        let bookmarkCount = bookmarkManager.bookmarkedCount
        let bookmarkTab = tabBarController.viewControllers?[1]
        
        DispatchQueue.main.async {
            if bookmarkCount > 0 {
                bookmarkTab?.tabBarItem.badgeValue = "\(bookmarkCount)"
            } else {
                bookmarkTab?.tabBarItem.badgeValue = nil
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

