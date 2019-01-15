//
//  BundledStoryboardLoadable.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 15/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

protocol BundledStoryboardLoadable {}

extension BundledStoryboardLoadable where Self: UIViewController {
    static func fromBundledStoryboard(storyboardName: String = String(describing: Self.self),
                                      forViewController viewControllerType: UIViewController.Type? = nil,
                                      identifier: String? = nil) -> Self {
        let bundle: Bundle
            
        if let viewControllerType = viewControllerType {
            bundle = Bundle(for: viewControllerType)
        } else {
            bundle = Bundle(for: Self.self)
        }
        
        let storyboard = UIStoryboard(name: storyboardName, bundle: bundle)
        let identifier = identifier ?? String(describing: Self.self)
        
        if let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? Self {
            return viewController
        }
        
        print(#function, "⚠️ Can't load a view controller with identifier '\(identifier)' from storyboard '\(storyboardName)'")
        
        return Self()
    }
}

// MARK: - Load UINavigationController from storyboard

extension UINavigationController: BundledStoryboardLoadable {
    static func fromBundledStoryboard(rootViewControllerType: UIViewController.Type) -> UINavigationController {
        return fromBundledStoryboard(storyboardName: String(describing: rootViewControllerType),
                                     forViewController: rootViewControllerType)
    }
}
