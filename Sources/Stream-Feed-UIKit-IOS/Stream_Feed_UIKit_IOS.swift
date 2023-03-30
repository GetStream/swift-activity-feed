import UIKit
import GetStream

public struct StreamFeedUIKitIOS {
    
    public static func makeTimeLineVC(feedSlug: String = "timeline", userId: String) -> ActivityFeedViewController {
        let timeLineVC = ActivityFeedViewController.fromBundledStoryboard()
        let nav = UINavigationController(rootViewController: timeLineVC)
        let flatFeed = Client.shared.flatFeed(feedSlug: feedSlug, userId: userId)
        timeLineVC.presenter = FlatFeedPresenter<Activity>(flatFeed: flatFeed,
                                                           reactionTypes: [.comments, .reposts, .likes])
        
        
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
        let customUser = CustomUser(id: userId, name: displayName)//, profileImage: profileImage)
        
        Client.shared.create(user: customUser, getOrCreate: true) { result in
            do {
                let retrivedUser = try result.get()
                print("BNBN Create User \(retrivedUser.name)")
                //  print("BNBN Create User \(retrivedUser.profileImage)")
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
        let customUser = CustomUser(id: userId, name: displayName)//, profileImage: profileImage)
        
        Client.shared.update(user: customUser) { result in
            do {
                let retrivedUser = try result.get()
                print("BNBN Create User \(retrivedUser.name)")
                //     print("BNBN Create User \(retrivedUser.profileImage)")
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
        let customUser = CustomUser(id: userId, name: displayName)//, profileImage: profileImage)
        
        Client.shared.setupUser(customUser, token: token) { result in
            do {
                let retrivedUser = try result.get()
                print("BNBN \(retrivedUser.name)")
                //print("BNBN \(retrivedUser.profileImage)")
                print("BNBN \(retrivedUser.id)")
                completion(nil)
            }
            catch {
                print("BNBN ERROR, \(error.localizedDescription)")
                completion(error)
            }
        }
    }
    
}

final class CustomUser: GetStream.User {
    private enum CodingKeys: String, CodingKey {
        case name
      //  case profileImage
    }

    var name: String
   // var profileImage: String

    init(id: String, name: String) { //, profileImage: String) {
        self.name = name
      //  self.profileImage = profileImage
        super.init(id: id)
    }

    required init(from decoder: Decoder) throws {
        let dataContainer = try decoder.container(keyedBy: DataCodingKeys.self)
        let container = try dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        name = try container.decode(String.self, forKey: .name)
       // profileImage = try container.decode(String.self, forKey: .profileImage)
        try super.init(from: decoder)
    }

    required init(id: String) {
        fatalError("init(id:) has not been implemented")
    }

    override func encode(to encoder: Encoder) throws {
        var dataContainer = encoder.container(keyedBy: DataCodingKeys.self)
        var container = dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        try container.encode(name, forKey: .name)
        try super.encode(to: encoder)
    }
}
