//
//  UINavigationController+Extensions.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 16/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

// MARK: - Child View Controllers

extension UINavigationController {
    
    /// Returns the previous view controller from the stack of navigation view controllers.
    public func previousViewController() -> UIViewController? {
        guard viewControllers.count > 1 else {
            return nil
        }
        
        return viewControllers[viewControllers.count - 2]
    }
    
    /// Returns the first founded view controller of a given type.
    public func findFirst<T: UIViewController>(viewControllerType: T.Type) -> T? {
        return find(viewControllerType: viewControllerType, in: viewControllers)
    }
    
    /// Returns the last founded view controller of a given type.
    public func findLast<T: UIViewController>(viewControllerType: T.Type) -> T? {
        return find(viewControllerType: viewControllerType, in: viewControllers.reversed())
    }
    
    private func find<T: UIViewController>(viewControllerType: T.Type, in viewControllers: [UIViewController]) -> T? {
        guard viewControllers.count > 0 else {
            return nil
        }
        
        for viewController in viewControllers {
            if let viewController = viewController as? T {
                return viewController
            }
        }
        
        return nil
    }
}

// MARK: - Transparency

extension UINavigationController {
    
    /// Removes the default background from the navigation bar.
    public func presentTransparentNavigationBar(animated: Bool = true, for barMetrics: UIBarMetrics = .default) {
        navigationBar.setBackgroundImage(UIImage(), for: barMetrics)
        navigationBar.isTranslucent = true
        setNavigationBarHidden(false, animated: animated)
        hideNavigationBarBottomLine()
    }
    
    /// Presents the not translucent background with a given color.
    public func presentNavigationBar(with backgroundColor: UIColor, animated: Bool = true, for barMetrics: UIBarMetrics = .default) {
        navigationBar.setBackgroundImage(UIImage(), for: barMetrics)
        navigationBar.isTranslucent = false
        navigationBar.backgroundColor = backgroundColor
        setNavigationBarHidden(false, animated: animated)
        hideNavigationBarBottomLine()
    }
    
    /// Restores the default navigation bar appearance.
    public func restoreDefaultNavigationBar(animated: Bool = true) {
        let backgroundImage = UINavigationBar.appearance().backgroundImage(for: .default)
        navigationBar.setBackgroundImage(backgroundImage, for: .default)
        navigationBar.isTranslucent = UINavigationBar.appearance().isTranslucent
        navigationBar.shadowImage = UINavigationBar.appearance().shadowImage
        setNavigationBarHidden(false, animated: animated)
    }
    
    /// Hides the bottom line of the navigation bar.
    public func hideNavigationBarBottomLine() {
        navigationBar.shadowImage = UIImage()
    }
}

// MARK: - Back Button

extension UIViewController {
    /// Hides the back button title from the navigation bar.
    public func hideBackButtonTitle() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
