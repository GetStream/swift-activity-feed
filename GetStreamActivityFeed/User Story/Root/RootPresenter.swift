//
//  AppPresenter.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 14/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import GetStream

final class RootPresenter {
    
    let router: RootRouter
    
    init(router: RootRouter) {
        self.router = router
    }
    
    func setup() {
        guard Client.shared.isValid else {
            router.showClientInfo()
            return
        }
        
        guard let token = Bundle.main.streamValue(for: .streamToken) else {
            router.showClientInfo("⚠️ Token is wrong\n\nThe payload doesn't contain an userId or it's empty.")
            return
        }
        
        if User.current != nil {
            router.showTabBar()
            return
        }
        
        guard let currentUserId = token.userId else {
            return
        }
        
        Client.shared.update(user: User(name: "", id: currentUserId)) { [weak self] result in
            if let error = result.error {
                self?.router.showClientInfo(error.localizedDescription)
            } else {
                self?.router.showTabBar()
            }
        }
    }
}
