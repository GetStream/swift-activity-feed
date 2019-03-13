//
//  ActivityFeedBuilder.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 22/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import GetStream

final class ActivityFeedBuilder {
    
    weak var profileBuilder: ProfileBuilder?
    
    func flatFeedNavigationController(feedSlug: String) -> UINavigationController {
        let navigationController = UINavigationController.fromBundledStoryboard(name: ActivityFeedViewController.storyboardName,
                                                                                bundle: Bundle.main)
        
        if let flatFeedViewController = navigationController.viewControllers.first as? ActivityFeedViewController,
            let flatFeed = Client.shared.flatFeed(feedSlug: feedSlug) {
            flatFeedViewController.presenter = FlatFeedPresenter<Activity>(flatFeed: flatFeed)
            flatFeedViewController.profileBuilder = profileBuilder
        }
        
        return navigationController
    }
    
    func activityFeedViewController(feedId: FeedId) -> ActivityFeedViewController {
        let flatFeed = Client.shared.flatFeed(feedId)
        let flatFeedViewController = ActivityFeedViewController.fromBundledStoryboard()
        flatFeedViewController.presenter = FlatFeedPresenter<Activity>(flatFeed: flatFeed)
        flatFeedViewController.profileBuilder = profileBuilder
        
        return flatFeedViewController
    }
}
