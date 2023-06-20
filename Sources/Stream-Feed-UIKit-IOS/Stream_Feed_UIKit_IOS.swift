import UIKit
import GetStream

public struct StreamFeedUIKitIOS {
    
    public static func makeTimeLineVC(feedSlug: String, userId: String, isCurrentUser: Bool, reportUserAction: @escaping ((String, String) -> Void), shareTimeLinePostAction:  @escaping ((String?) -> Void)) -> ActivityFeedViewController {
        let timeLineVC = ActivityFeedViewController.fromBundledStoryboard()
        timeLineVC.isCurrentUser = isCurrentUser
        timeLineVC.reportUserAction = reportUserAction
        timeLineVC.shareTimeLinePostAction = shareTimeLinePostAction
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
    
    public static func makePostDetailsVC(with activityId: String,
                                  currentUserId: String,
                                  reportUserAction: @escaping ((String, String) -> Void),
                                  shareTimeLinePostAction:  @escaping ((String?) -> Void),
                                  completion: @escaping (Result<PostDetailTableViewController, Error>) -> Void) {
        
        StreamFeedUIKitIOS.loadActivityByID(activityId: activityId) { result in
            do {
                let activity = try result.get()
                let isCurrentUser: Bool = activity.actor.id == currentUserId
                let activityDetailTableViewController = self.createActivityDetailTableViewController(activity: activity,
                                                                                                     isCurrentUser: isCurrentUser,
                                                                                                     reportUserAction: reportUserAction,
                                                                                                     shareTimeLinePostAction: shareTimeLinePostAction)
                completion(.success(activityDetailTableViewController))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private static func createActivityDetailTableViewController(activity: Activity,
                                                         isCurrentUser: Bool,
                                                         reportUserAction: @escaping ((String, String) -> Void),
                                                         shareTimeLinePostAction:  @escaping ((String?) -> Void)) -> PostDetailTableViewController {
        
        let activityDetailTableViewController = PostDetailTableViewController()
        guard let flatFeed = Client.shared.flatFeed(feedSlug: "user") else { return PostDetailTableViewController() }
        let flatFeedPresenter = FlatFeedPresenter<Activity>(flatFeed: flatFeed,
                                                            reactionTypes: [.comments, .likes])
        let reactionPresenter = ReactionPresenter()
        
        let activityPresenter = ActivityPresenter(activity: activity, reactionPresenter: reactionPresenter, reactionTypes: [.comments, .likes])
        
        activityDetailTableViewController.reportUserAction = reportUserAction
        activityDetailTableViewController.shareTimeLinePostAction = shareTimeLinePostAction
        activityDetailTableViewController.isCurrentUser = isCurrentUser
        activityDetailTableViewController.presenter = flatFeedPresenter
        activityDetailTableViewController.activityPresenter = activityPresenter
        activityDetailTableViewController.sections = [.activity, .comments]
        
        return activityDetailTableViewController
    }

    
    public static func loadActivityByID(activityId: String, completion: @escaping (Result<Activity, Error>) -> Void) {
        Client.shared.get(typeOf: Activity.self, activityIds: [activityId]) { result in
            do {
                let response = try result.get()
                guard let activity = response.results.first else {
                    return
                }
                completion(.success(activity))
            } catch let responseError {
                completion(.failure(responseError))
            }
        }
    }
    
    public static func setupStream(apiKey: String, appId: String, region: BaseURL.Location, logsEnabled: Bool = true) {
        if Client.shared.token.isEmpty {
            Client.shared = Client(apiKey: apiKey,
                                   appId: appId,
                                   baseURL: BaseURL(location: region),
                                   logsEnabled: logsEnabled)
        }
        Client.config = .init(apiKey: apiKey, appId: appId, baseURL: BaseURL(location: region), logsEnabled: logsEnabled)
        UIFont.overrideInitialize()
    }
    
    
    public static func logOut() {
        Client.shared = Client(apiKey: "", appId: "")
        Client.shared.currentUser = nil
        Client.shared.currentUserId = nil
        Client.shared.token = ""
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
