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
        let navigationController = UINavigationController.fromBundledStoryboard(name: FlatFeedViewController.storyboardName,
                                                                                bundle: Bundle.main)
        
        if let flatFeedViewController = navigationController.viewControllers.first as? FlatFeedViewController,
            let flatFeed = Client.shared.flatFeed(feedSlug: feedSlug) {
            flatFeedViewController.presenter = FlatFeedPresenter<Activity>(flatFeed: flatFeed)
            flatFeedViewController.profileBuilder = profileBuilder
        }
        
        return navigationController
    }
    
    func flatFeedViewController(feedId: FeedId) -> FlatFeedViewController {
        let flatFeed = Client.shared.flatFeed(feedId)
        let flatFeedViewController = FlatFeedViewController.fromBundledStoryboard()
        flatFeedViewController.presenter = FlatFeedPresenter<Activity>(flatFeed: flatFeed)
        flatFeedViewController.profileBuilder = profileBuilder
        
        return flatFeedViewController
    }
}
