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
        tabBar.viewControllers = [UIViewController(), UIViewController()]
        tabBar.view.backgroundColor = .white
        return tabBar
    }
}
