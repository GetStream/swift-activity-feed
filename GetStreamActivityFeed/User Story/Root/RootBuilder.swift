//
//  RootBuilder.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 15/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import GetStream

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
        
        let flatFeed = activityFeedBuilder.flatFeedNavigationController(feedSlug: "timeline")
        let notifications = notificationsBuilder.notificationsNavigationController(feedSlug: "notification")
        
        if  let flatFeedViewController = flatFeed.findFirst(viewControllerType: FlatFeedViewController.self),
            let notificationsViewController = notifications.findFirst(viewControllerType: NotificationsViewController.self) {
            flatFeedViewController.notificationsPresenter = notificationsViewController.presenter
        }
        
        tabBar.viewControllers = [flatFeed,
                                  notifications,
                                  profileBuilder.profileNavigationController(user: User.current)]
        return tabBar
    }
}
