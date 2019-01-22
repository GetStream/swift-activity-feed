//
//  ProfileBuilder.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 16/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

final class ProfileBuilder {
    
    weak var activityFeedBuilder: ActivityFeedBuilder?
    
    func profileNavigationController(user: User?) -> UINavigationController {
        let navigationController = UINavigationController.fromBundledStoryboard(name: ProfileViewController.storyboardName,
                                                                                bundle: Bundle.main)
        
        if let viewController = navigationController.viewControllers.first as? ProfileViewController {
            viewController.user = user
            viewController.isCurrentUser = true
            viewController.builder = self
        }
        
        return navigationController
    }
    
    func editProfileNavigationController(_ setup: (_ editProfileViewController: EditProfileViewController) -> Void) -> UINavigationController {
        let navigationController = UINavigationController.fromBundledStoryboard(name: ProfileViewController.storyboardName,
                                                                                id: String(describing: EditProfileViewController.self),
                                                                                bundle: Bundle.main)
        
        if let viewController = navigationController.viewControllers.first as? EditProfileViewController {
            viewController.user = UIApplication.shared.appDelegate.currentUser
            setup(viewController)
        }
        
        return navigationController
    }
    
    func profileViewController(user: User?) -> ProfileViewController {
        let profileViewController = ProfileViewController.fromBundledStoryboard()
        profileViewController.user = user
        
        return profileViewController
    }
}
