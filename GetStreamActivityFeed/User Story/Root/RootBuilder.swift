//
//  RootBuilder.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 15/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

final class RootBuilder {
    
    var rootTabBarController: UITabBarController {
        let tabBar = UITabBarController()
        tabBar.viewControllers = [profileViewController(user: UIApplication.shared.appDelegate.currentUser)]
        tabBar.view.backgroundColor = .white
        return tabBar
    }
    
    func profileViewController(user: User?) -> UIViewController {
        let navigationController = UINavigationController.fromBundledStoryboard(rootViewControllerType: ProfileViewController.self)
        
        if let viewController = navigationController.viewControllers.first as? ProfileViewController {
            viewController.user = user
        }
        
        return navigationController
    }
}
