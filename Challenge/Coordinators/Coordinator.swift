import UIKit

// MARK: - Coordinator Protocol
@MainActor
protocol Coordinator: AnyObject {
    func start()
}
