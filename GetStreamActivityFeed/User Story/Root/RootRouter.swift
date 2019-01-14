//
//  AppRouter.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 14/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

final class RootRouter {
    func showClientInfo(_ info: String? = nil) {
        let viewController = ClientInfoViewController.fromBundledNib()
        viewController.info = info
        UIApplication.shared.rootViewController.present(viewController, animated: false)
    }
    
    func showTabBar() {
    }
}
