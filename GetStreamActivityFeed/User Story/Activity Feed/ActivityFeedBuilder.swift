//
//  ActivityFeedBuilder.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 22/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

final class ActivityFeedBuilder {
    
    weak var profileBuilder: ProfileBuilder?
    
    func flatFeedNavigationController(feedSlug: String) -> UINavigationController {
        let navigationController = UINavigationController.fromBundledStoryboard(name: "ActivityFeed", bundle: Bundle.main)
        
        if let flatFeedViewController = navigationController.viewControllers.first as? FlatFeedViewController,
            let flatFeed = UIApplication.shared.appDelegate.client?.flatFeed(feedSlug: feedSlug) {
            flatFeedViewController.presenter = FlatFeedPresenter<Activity>(flatFeed: flatFeed)
            flatFeedViewController.profileBuilder = profileBuilder
        }
        
        return navigationController
    }
    
    func flatFeedViewController(feedSlug: String) -> FlatFeedViewController {
        let flatFeedViewController = FlatFeedViewController.fromBundledStoryboard()
        
        if let flatFeed = UIApplication.shared.appDelegate.client?.flatFeed(feedSlug: feedSlug) {
            flatFeedViewController.presenter = FlatFeedPresenter<Activity>(flatFeed: flatFeed)
            flatFeedViewController.profileBuilder = profileBuilder
        }
        
        return flatFeedViewController
    }
}
