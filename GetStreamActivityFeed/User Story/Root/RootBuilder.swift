//
//  RootBuilder.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 15/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

final class RootBuilder {
    
    let activityFeedBuilder: ActivityFeedBuilder
    let notificationsBuilder: NotificationsBuilder
    let profileBuilder: ProfileBuilder

    init(activityFeedBuilder: ActivityFeedBuilder,
         notificationsBuilder: NotificationsBuilder,
         profileBuilder: ProfileBuilder) {
        self.activityFeedBuilder = activityFeedBuilder
        self.notificationsBuilder = notificationsBuilder
        self.profileBuilder = profileBuilder
    }
    
    var rootTabBarController: UITabBarController {
        let tabBar = UITabBarController()
        tabBar.view.backgroundColor = .white
        tabBar.tabBar.isTranslucent = false
        
        tabBar.viewControllers = [activityFeedBuilder.flatFeedNavigationController(feedSlug: "timeline"),
                                  notificationsBuilder.notificationsNavigationController(feedSlug: "notification"),
                                  profileBuilder.profileNavigationController(user: UIApplication.shared.appDelegate.currentUser)]
        return tabBar
    }
}
