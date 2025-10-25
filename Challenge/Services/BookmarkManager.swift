import Foundation

// Abstraction for dependency injection
protocol BookmarkManaging {
    var bookmarkedUsers: [User] { get }
    func isBookmarked(_ user: User) -> Bool
    func addBookmark(_ user: User)
    func removeBookmark(_ user: User)
    func toggleBookmark(_ user: User)
    var bookmarkedCount: Int { get }
    func clearAllBookmarks()
}

// MARK: - BookmarkManager
class BookmarkManager: BookmarkManaging {
    
    private let userDefaults: UserDefaults
    private let bookmarksKey = "BookmarkedUsers"
    
    // Notification for bookmark changes
    static let bookmarkDidChangeNotification = NSNotification.Name("BookmarkDidChange")
    
    // Shared instance for transitional use (prefer injection)
    static let shared = BookmarkManager()
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Public Methods
    
    /// Get all bookmarked users
    var bookmarkedUsers: [User] {
        guard let data = userDefaults.data(forKey: bookmarksKey),
              let users = try? JSONDecoder().decode([User].self, from: data) else {
            return []
        }
        return users
    }
    
    /// Check if a user is bookmarked
    func isBookmarked(_ user: User) -> Bool {
        return bookmarkedUsers.contains(where: { $0.uniqueID == user.uniqueID })
    }
    
    /// Add a user to bookmarks
    func addBookmark(_ user: User) {
        var currentBookmarks = bookmarkedUsers
        
        // Avoid duplicates
        if !currentBookmarks.contains(where: { $0.uniqueID == user.uniqueID }) {
            currentBookmarks.append(user)
            saveBookmarks(currentBookmarks)
            
            print("✅ Added bookmark for \(user.fullName)")
            
            // Post notification
            NotificationCenter.default.post(name: BookmarkManager.bookmarkDidChangeNotification,
                                          object: nil,
                                          userInfo: ["action": "added", "user": user])
        }
    }
    
    /// Remove a user from bookmarks
    func removeBookmark(_ user: User) {
        var currentBookmarks = bookmarkedUsers
        currentBookmarks.removeAll { $0.uniqueID == user.uniqueID }
        saveBookmarks(currentBookmarks)
        
        print("🗑️ Removed bookmark for \(user.fullName)")
        
        // Post notification
        NotificationCenter.default.post(name: BookmarkManager.bookmarkDidChangeNotification,
                                      object: nil,
                                      userInfo: ["action": "removed", "user": user])
    }
    
    /// Toggle bookmark status for a user
    func toggleBookmark(_ user: User) {
        if isBookmarked(user) {
            removeBookmark(user)
        } else {
            addBookmark(user)
        }
    }
    
    /// Get count of bookmarked users
    var bookmarkedCount: Int {
        return bookmarkedUsers.count
    }
    
    /// Clear all bookmarks
    func clearAllBookmarks() {
        userDefaults.removeObject(forKey: bookmarksKey)
        
        print("🗑️ Cleared all bookmarks")
        
        // Post notification
        NotificationCenter.default.post(name: BookmarkManager.bookmarkDidChangeNotification,
                                      object: nil,
                                      userInfo: ["action": "cleared"])
    }
    
    // MARK: - Private Methods
    
    private func saveBookmarks(_ users: [User]) {
        do {
            let data = try JSONEncoder().encode(users)
            userDefaults.set(data, forKey: bookmarksKey)
            userDefaults.synchronize()
        } catch {
            print("❌ Failed to save bookmarks: \(error)")
        }
    }
}
