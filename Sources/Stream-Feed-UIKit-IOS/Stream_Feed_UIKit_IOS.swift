import UIKit
import GetStream

public struct StreamFeedUIKitIOS {
    
    public static func makeTimeLineVC(feedSlug: String, userId: String, isCurrentUserTimeline: Bool, profilePictureURL: String) -> ActivityFeedViewController {
        let timeLineVC = ActivityFeedViewController.fromBundledStoryboard()
        timeLineVC.isCurrentUserTimeline = isCurrentUserTimeline
        timeLineVC.profilePictureURL = profilePictureURL
        timeLineVC.modalPresentationStyle = .fullScreen
        let nav = UINavigationController(rootViewController: timeLineVC)
        nav.modalPresentationStyle = .fullScreen
        let flatFeed = Client.shared.flatFeed(feedSlug: feedSlug, userId: userId)
        let presenter = FlatFeedPresenter<Activity>(flatFeed: flatFeed,
                                                    reactionTypes: [.likes, .comments])
        timeLineVC.presenter = presenter
        
        return nav.viewControllers.first as! ActivityFeedViewController
    }
    
    
    public static func makeEditPostVC() -> EditPostViewController {
        guard let userFeedId: FeedId = FeedId(feedSlug: "user") else { return EditPostViewController() }
        let editPostViewController = EditPostViewController.fromBundledStoryboard()
        editPostViewController.presenter = EditPostPresenter(flatFeed: Client.shared.flatFeed(userFeedId),view: editPostViewController)
        editPostViewController.modalPresentationStyle = .fullScreen
        return editPostViewController
    }
    
    
    public static func setupStream(apiKey: String, appId: String, region: BaseURL.Location, logsEnabled: Bool = true) {
        Client.config = .init(apiKey: apiKey, appId: appId, baseURL: BaseURL(location: region), logsEnabled: logsEnabled)
        UIFont.overrideInitialize()
    }
    
    public static func createUser(userId: String, displayName: String, profileImage: String, completion: @escaping ((Error?) -> Void)) {
        let customUser = User(name: displayName, id: userId, profileImage: profileImage)
        Client.shared.create(user: customUser, getOrCreate: true) { result in
            do {
                let retrivedUser = try result.get()
                completion(nil)
            }
            catch {
                completion(error)
            }
        }
    }
    
    
    public static func updateUser(userId: String, displayName: String, profileImage: String, completion: @escaping ((Error?) -> Void)) {
        let customUser = User(name: displayName, id: userId, profileImage: profileImage)
        Client.shared.update(user: customUser) { result in
            do {
                let retrivedUser = try result.get()
                var currentUser = Client.shared.currentUser as? User
                if !profileImage.isEmpty {
                    currentUser?.avatarURL = URL(string: profileImage)!
                }
                if !displayName.isEmpty {
                    currentUser?.name = displayName
                }
                completion(nil)
            }
            catch {
                completion(error)
            }
        }
    }
    
    public static func registerUser(withToken token: String, userId: String, displayName: String, profileImage: String, completion: @escaping ((Error?) -> Void)) {
        let customUser = User(name: displayName, id: userId, profileImage: profileImage)
        Client.shared.setupUser(customUser, token: token) { result in
            do {
                let retrivedUser = try result.get()
                let currentUser = Client.shared.currentUser as? User
                if !profileImage.isEmpty {
                    currentUser?.avatarURL = URL(string: profileImage)!
                }
                completion(nil)
            }
            catch {
                completion(error)
            }
        }
    }
    
}
