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
    
    public func previousViewController() -> UIViewController? {
        guard viewControllers.count > 1 else {
            return nil
        }
        
        return viewControllers[viewControllers.count - 2]
    }
    
    public func findFirst<T: UIViewController>(viewControllerType: T.Type) -> T? {
        return find(viewControllerType: viewControllerType, in: viewControllers)
    }
    
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
    
    public func presentTransparentNavigationBar(animated: Bool = true) {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.isTranslucent = true
        setNavigationBarHidden(false, animated: animated)
        hideNavigationBarBottomLine()
    }
    
    public func presentNavigationBar(with backgroundColor: UIColor, animated: Bool = true) {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.isTranslucent = false
        navigationBar.backgroundColor = backgroundColor
        setNavigationBarHidden(false, animated: animated)
        hideNavigationBarBottomLine()
    }
    
    public func restoreDefaultNavigationBar(animated: Bool = true) {
        let backgroundImage = UINavigationBar.appearance().backgroundImage(for: .default)
        navigationBar.setBackgroundImage(backgroundImage, for: .default)
        navigationBar.isTranslucent = UINavigationBar.appearance().isTranslucent
        navigationBar.shadowImage = UINavigationBar.appearance().shadowImage
        setNavigationBarHidden(false, animated: animated)
    }
    
    public func hideNavigationBarBottomLine() {
        navigationBar.shadowImage = UIImage()
    }
}

// MARK: - Back Button

extension UIViewController {
    public func hideBackButtonTitle() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
