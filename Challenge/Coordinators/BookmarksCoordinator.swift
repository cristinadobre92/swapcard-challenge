import UIKit

class BookmarksCoordinator: Coordinator {
    var navigationController: UINavigationController
    private var userDetailCoordinator: UserDetailCoordinator?
    private let bookmarkManager: BookmarkManaging
    
    init(navigationController: UINavigationController, bookmarkManager: BookmarkManaging) {
        self.navigationController = navigationController
        self.bookmarkManager = bookmarkManager
    }
    
    
    func start() {
        showBookmarks()
    }
    
    private func showBookmarks() {
        let bookmarksVC = BookmarksViewController(
            bookmarkManager: bookmarkManager
        )
        bookmarksVC.coordinator = self
        navigationController.pushViewController(bookmarksVC, animated: false)
    }
    
    func showUserDetail(for user: User) {
        userDetailCoordinator = UserDetailCoordinator(
            navigationController: navigationController,
            user: user,
            bookmarkManager: bookmarkManager
        )
        userDetailCoordinator?.delegate = self
        userDetailCoordinator?.start()
    }
}

// MARK: - UserDetailCoordinatorDelegate
extension BookmarksCoordinator: UserDetailCoordinatorDelegate {
    func userDetailCoordinatorDidFinish(_ coordinator: UserDetailCoordinator) {
        userDetailCoordinator = nil
    }
}
