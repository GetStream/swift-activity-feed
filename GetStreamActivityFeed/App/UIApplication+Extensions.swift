//
//  UIApplication+Extensions.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 14/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

extension UIApplication {
    
    var appDelegate: AppDelegate {
        if let delegate = delegate as? AppDelegate {
            return delegate
        }
        
        fatalError("AppDelegate not found")
    }
    
    var window: UIWindow {
        if let window = appDelegate.window {
            return window
        }
        
        print("🚨 Root window missed!")
        
        return UIWindow()
    }
    
    var rootViewController: RootViewController {
        if let rootViewController = window.rootViewController as? RootViewController {
            return rootViewController
        }
        
        print("🚨 Root view controller missed!")
        
        return RootViewController()
    }
}
