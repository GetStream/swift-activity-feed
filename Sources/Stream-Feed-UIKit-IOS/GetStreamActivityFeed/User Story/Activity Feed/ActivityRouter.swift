//
//  ActivityRouter.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 01/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import GetStream

struct ActivityRouter {
    
    let viewController: UIViewController
    var profileBuilder: ProfileBuilder?
    
    init(viewController: UIViewController, profileBuilder: ProfileBuilder?) {
        self.viewController = viewController
        self.profileBuilder = profileBuilder
    }
    
    func show(user: User) {
        if let profileViewCotroller = profileBuilder?.profileViewController(user: user) {
            profileViewCotroller.builder = profileBuilder
            viewController.navigationController?.pushViewController(profileViewCotroller, animated: true)
        }
    }
}
