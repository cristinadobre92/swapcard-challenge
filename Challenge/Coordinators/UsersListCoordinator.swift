import UIKit
import APIServiceKit
import SharedModelsKit
import BookmarksKit
import DesignKit

class UsersListCoordinator: Coordinator {
    var navigationController: UINavigationController
    private var userDetailCoordinator: UserDetailCoordinator?
    private let bookmarkManager: BookmarkManaging
    private let apiService: APIServicing
    private let imageLoader: ImageLoading
    
    init(
        navigationController: UINavigationController,
        bookmarkManager: BookmarkManaging,
        apiService: APIServicing,
        imageLoader: ImageLoading
    ) {
        self.navigationController = navigationController
        self.bookmarkManager = bookmarkManager
        self.apiService = apiService
        self.imageLoader = imageLoader
    }
    
    func start() {
        showUsersList()
    }
    
    private func showUsersList() {
        let usersListVC = UsersListViewController(
            bookmarkManager: bookmarkManager,
            apiService: apiService,
            imageLoader: imageLoader
        )
        usersListVC.coordinator = self
        navigationController.pushViewController(usersListVC, animated: false)
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
extension UsersListCoordinator: UserDetailCoordinatorDelegate {
    func userDetailCoordinatorDidFinish(_ coordinator: UserDetailCoordinator) {
        userDetailCoordinator = nil
    }
}

