import UIKit
import SharedModelsKit
import BookmarksKit
import DesignKit

@MainActor
class BookmarksCoordinator: Coordinator {
    var navigationController: UINavigationController
    private var userDetailCoordinator: UserDetailCoordinator?
    private let bookmarkManager: BookmarkManaging
    private let imageLoader: ImageLoading
    
    init(navigationController: UINavigationController, bookmarkManager: BookmarkManaging, imageLoader: ImageLoading) {
        self.navigationController = navigationController
        self.bookmarkManager = bookmarkManager
        self.imageLoader = imageLoader
    }
    
    
    func start() {
        showBookmarks()
    }
    
    private func showBookmarks() {
        let bookmarksVC = BookmarksViewController(
            bookmarkManager: bookmarkManager,
            imageLoader: imageLoader
        )
        bookmarksVC.coordinator = self
        navigationController.pushViewController(bookmarksVC, animated: false)
    }
    
    func showUserDetail(for user: User) {
        userDetailCoordinator = UserDetailCoordinator(
            navigationController: navigationController,
            user: user,
            bookmarkManager: bookmarkManager,
            imageLoader: imageLoader
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

