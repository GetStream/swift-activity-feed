//
//  RootBuilder.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 15/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

final class RootBuilder {
    
    let profileBuilder = ProfileBuilder()
    
    var rootTabBarController: UITabBarController {
        let tabBar = UITabBarController()
        
        tabBar.viewControllers = [flatFeedViewController,
                                  profileBuilder.profileViewController(user: UIApplication.shared.appDelegate.currentUser)]
        
        tabBar.view.backgroundColor = .white
        return tabBar
    }
    
    var flatFeedViewController: UIViewController {
        let navigationController = UINavigationController.fromBundledStoryboard(name: "ActivityFeed", bundle: Bundle.main)
        
        if let flatFeedViewController = navigationController.viewControllers.first as? FlatFeedViewController,
            let flatFeed = UIApplication.shared.appDelegate.client?.flatFeed(feedSlug: "timeline") {
            flatFeedViewController.presenter = FlatFeedPresenter<CustomActivity>(flatFeed: flatFeed)
        }
        
        return navigationController
    }
}
