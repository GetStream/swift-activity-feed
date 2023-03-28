//
//  NotificationsBuilder.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 14/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import GetStream

final class NotificationsBuilder {
    
    weak var notificationsViewController: NotificationsViewController?
    
    func notificationsNavigationController(feedSlug: String) -> UINavigationController {
        let navigationController = UINavigationController.fromBundledStoryboard(name: NotificationsViewController.storyboardName,
                                                                                bundle: Bundle.main)
        
        if let notificationsViewController = navigationController.viewControllers.first as? NotificationsViewController,
            let userId = Client.shared.currentUserId {
            let notificationFeed = NotificationFeed(FeedId(feedSlug: feedSlug, userId: userId))
            notificationsViewController.presenter = NotificationsPresenter(notificationFeed)
        }
        
        return navigationController
    }
}
