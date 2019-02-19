//
//  UITabBarController+Extensions.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 18/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

extension UITabBarController {
    
    /// Select a tab item matched with a given view controller type.
    func selectTab(with viewControllerType: UIViewController.Type) {
        guard let viewControllers = viewControllers else {
            return
        }
        
        var index = selectedIndex
        
        for (currentIndex, viewController) in viewControllers.enumerated() {
            if type(of: viewController) == viewControllerType {
                index = currentIndex
                break
            }
            
            if let viewController = viewController as? UINavigationController,
                let first = viewController.viewControllers.first,
                type(of: first) == viewControllerType {
                index = currentIndex
                break
            }
        }
        
        if index != selectedIndex {
            selectedIndex = index
        }
    }
    
    /// Find the first view controller of the given type in the tabbar and in the tabbar/navigation controllers.
    func find<T: UIViewController>(viewControllerType: T.Type) -> T? {
        guard let viewControllers = viewControllers else {
            return nil
        }
        
        for viewController in viewControllers {
            if let viewController = viewController as? T {
                return viewController
            }
            
            if let viewController = viewController as? UINavigationController,
                let first = viewController.viewControllers.first as? T {
                return first
            }
        }
        
        return nil
    }
}
