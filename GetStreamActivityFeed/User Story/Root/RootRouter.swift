//
//  AppRouter.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 14/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

final class RootRouter {
    var builder = RootBuilder()
    weak var rootViewController: RootViewController?
    
    init(rootViewController: RootViewController) {
        self.rootViewController = rootViewController
    }
    
    func showClientInfo(_ info: String? = nil) {
        if let info = info {
            rootViewController?.warningLabel.text = info
        }
        
        rootViewController?.warningView.isHidden = false
    }
    
    func showTabBar() {
        guard let rootViewController = rootViewController else {
            return
        }
        
        rootViewController.warningView.removeFromSuperview()
        rootViewController.add(viewController: builder.rootTabBarController)
    }
}
