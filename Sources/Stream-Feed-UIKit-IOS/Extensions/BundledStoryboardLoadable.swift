//
//  BundledStoryboardLoadable.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 15/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

public protocol BundledStoryboardLoadable {
    static var storyboardName: String { get }
}

extension BundledStoryboardLoadable {
    public static var storyboardName: String {
        return String(describing: Self.self)
    }
}

extension BundledStoryboardLoadable where Self: UIViewController {
    public static func fromBundledStoryboard(name: String = Self.storyboardName,
                                      id: String? = nil,
                                      bundle: Bundle? = nil) -> Self {
        //let bundle: Bundle = bundle ?? Bundle(for: Self.self)
        let storyboard = UIStoryboard(name: name, bundle: Bundle.module)
        let identifier = id ?? String(describing: Self.self)
        
        if let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? Self {
            return viewController
        }
        
        print(#function, "⚠️ Can't load a view controller with identifier '\(identifier)' from storyboard '\(storyboardName)'")
        
        return Self()
    }
}

// MARK: - Load UINavigationController from storyboard

extension UINavigationController: BundledStoryboardLoadable {}
