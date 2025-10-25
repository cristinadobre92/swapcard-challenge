import UIKit

class MainTabBarController: UITabBarController {
    
    private var bookmarkBadgeObserver: NSObjectProtocol?
    private let bookmarkManager: BookmarkManaging
    private let apiService: APIServicing
    
    init(bookmarkManager: BookmarkManaging, apiService: APIServicing) {
        self.bookmarkManager = bookmarkManager
        self.apiService = apiService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
        setupBookmarkBadgeObserver()
        updateBookmarkBadge()
    }
    
    deinit {
        if let observer = bookmarkBadgeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func setupTabs() {
        // Users List Tab
        let usersListVC = UsersListViewController(
            bookmarkManager: bookmarkManager,
            apiService: apiService
        )
        let usersNav = UINavigationController(rootViewController: usersListVC)
        usersNav.tabBarItem = UITabBarItem(
            title: "Users",
            image: UIImage(systemName: "person.2"),
            selectedImage: UIImage(systemName: "person.2.fill")
        )
        
        // Bookmarks Tab
        let bookmarksVC = BookmarksViewController(bookmarkManager: bookmarkManager)
        let bookmarksNav = UINavigationController(rootViewController: bookmarksVC)
        bookmarksNav.tabBarItem = UITabBarItem(
            title: "Bookmarks",
            image: UIImage(systemName: "bookmark"),
            selectedImage: UIImage(systemName: "bookmark.fill")
        )
        
        viewControllers = [usersNav, bookmarksNav]
    }
    
    private func setupAppearance() {
        // Configure tab bar appearance
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .systemGray
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func setupBookmarkBadgeObserver() {
        bookmarkBadgeObserver = NotificationCenter.default.addObserver(
            forName: BookmarkManager.bookmarkDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateBookmarkBadge()
        }
    }
    
    private func updateBookmarkBadge() {
        let bookmarkCount = bookmarkManager.bookmarkedCount
        let bookmarkTab = viewControllers?[1]
        
        if bookmarkCount > 0 {
            bookmarkTab?.tabBarItem.badgeValue = "\(bookmarkCount)"
        } else {
            bookmarkTab?.tabBarItem.badgeValue = nil
        }
    }
}
