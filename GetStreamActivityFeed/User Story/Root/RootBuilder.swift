//
//  RootBuilder.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 15/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

final class RootBuilder {
    
    let profileBuilder: ProfileBuilder
    let activityFeedBuilder: ActivityFeedBuilder
    
    init(profileBuilder: ProfileBuilder, activityFeedBuilder: ActivityFeedBuilder) {
        self.profileBuilder = profileBuilder
        self.activityFeedBuilder = activityFeedBuilder
    }
    
    var rootTabBarController: UITabBarController {
        let tabBar = UITabBarController()
        
        tabBar.viewControllers = [activityFeedBuilder.flatFeedNavigationController(feedSlug: "timeline"),
                                  profileBuilder.profileNavigationController(user: UIApplication.shared.appDelegate.currentUser)]
        
        tabBar.view.backgroundColor = .white
        return tabBar
    }
}
