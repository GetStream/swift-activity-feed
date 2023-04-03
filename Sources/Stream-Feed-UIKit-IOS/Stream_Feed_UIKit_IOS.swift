import UIKit
import GetStream

public struct StreamFeedUIKitIOS {
    
    public static func makeTimeLineVC(feedSlug: String, userId: String, isCurrentUser: Bool) -> ActivityFeedViewController {
        let timeLineVC = ActivityFeedViewController.fromBundledStoryboard()
        let nav = UINavigationController(rootViewController: timeLineVC)
        let flatFeed = Client.shared.flatFeed(feedSlug: feedSlug, userId: userId)
        let presenter = FlatFeedPresenter<Activity>(flatFeed: flatFeed,
                                                    reactionTypes: [.likes, .comments])
      
        if !isCurrentUser {
            presenter.follow(toTarget: FeedId(feedSlug: "user", userId: userId)) { error in
                if let error = error {
                    print("BNBN Follow Error \(error.localizedDescription)")
                }
                print("BNBN Follow Success")
            }
        }
   
        timeLineVC.presenter = presenter

        return nav.viewControllers.first as! ActivityFeedViewController
    }
    
    
    public static func makeEditPostVC() -> UIViewController {
        guard let userFeedId: FeedId = FeedId(feedSlug: "timeline") else { return UIViewController() }
        let editPostViewController = EditPostViewController.fromBundledStoryboard()
        editPostViewController.presenter = EditPostPresenter(flatFeed: Client.shared.flatFeed(userFeedId),
                                                             view: editPostViewController)
        return editPostViewController
    }
    
    
    public static func setupStream(apiKey: String, appId: String, region: BaseURL.Location, logsEnabled: Bool = true) {
        Client.config = .init(apiKey: apiKey, appId: appId, baseURL: BaseURL(location: region), logsEnabled: logsEnabled)
        UIFont.overrideInitialize()
    }
    
    public static func createUser(userId: String, displayName: String, profileImage: String, completion: @escaping ((Error?) -> Void)) {
        let customUser = User(name: displayName, id: userId)
        if !profileImage.isEmpty {
            customUser.avatarURL = URL(string: profileImage)
        }
        Client.shared.create(user: customUser, getOrCreate: true) { result in
            do {
                let retrivedUser = try result.get()
                print("BNBN Create User \(retrivedUser.name)")
                print("BNBN \(retrivedUser.avatarURL)")
                print("BNBN Create User \(retrivedUser.id)")
                completion(nil)
            }
            catch {
                print("BNBN ERROR, \(error.localizedDescription)")
                completion(error)
            }
        }
    }
    
    
    public static func updateUser(userId: String, displayName: String, profileImage: String, completion: @escaping ((Error?) -> Void)) {
        let customUser = User(name: displayName, id: userId)
        if !profileImage.isEmpty {
            customUser.avatarURL = URL(string: profileImage)
        }
        
        Client.shared.update(user: customUser) { result in
            do {
                let retrivedUser = try result.get()
                print("BNBN Create User \(retrivedUser.name)")
                print("BNBN \(retrivedUser.avatarURL)")
                print("BNBN Create User \(retrivedUser.id)")
                completion(nil)
            }
            catch {
                print("BNBN ERROR, \(error.localizedDescription)")
                completion(error)
            }
        }
    }
    
    public static func registerUser(withToken token: String, userId: String, displayName: String, profileImage: String, completion: @escaping ((Error?) -> Void)) {
        let customUser = User(name: displayName, id: userId)
        Client.shared.setupUser(customUser, token: token) { result in
            do {
                let retrivedUser = try result.get()
                print("BNBN \(retrivedUser.name)")
                print("BNBN \(retrivedUser.id)")
                let currentUser = Client.shared.currentUser as? User
                if !profileImage.isEmpty {
                    currentUser?.avatarURL = URL(string: profileImage)!
                    print("BNBN Avatar \(currentUser?.avatarURL)")
                }
                completion(nil)
            }
            catch {
                print("BNBN ERROR, \(error.localizedDescription)")
                completion(error)
            }
        }
    }
    
}
