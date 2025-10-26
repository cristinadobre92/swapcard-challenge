import UIKit
import APIServiceKit
import SharedModelsKit

class UsersListCoordinator: Coordinator {
    var navigationController: UINavigationController
    private var userDetailCoordinator: UserDetailCoordinator?
    private let bookmarkManager: BookmarkManaging
    private let apiService: APIServicing
    
    init(navigationController: UINavigationController, bookmarkManager: BookmarkManaging, apiService: APIServicing) {
        self.navigationController = navigationController
        self.bookmarkManager = bookmarkManager
        self.apiService = apiService
    }
    
    func start() {
        showUsersList()
    }
    
    private func showUsersList() {
        let usersListVC = UsersListViewController(bookmarkManager: bookmarkManager, apiService: apiService)
        usersListVC.coordinator = self
        navigationController.pushViewController(usersListVC, animated: false)
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
extension UsersListCoordinator: UserDetailCoordinatorDelegate {
    func userDetailCoordinatorDidFinish(_ coordinator: UserDetailCoordinator) {
        userDetailCoordinator = nil
    }
}

