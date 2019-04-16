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
        
        guard let currentUserId = Client.shared.currentUserId, !currentUserId.isEmpty else {
            router.showClientInfo("⚠️ Token is wrong\n\nThe payload doesn't contain an userId or it's empty.")
            return
        }
        
        Client.shared.createCurrentUser() { [weak self] in
            if let error = $0.error {
                self?.router.showClientInfo(error.localizedDescription)
            } else {
                Client.shared.getCurrentUser(typeOf: User.self, withFollowCounts: true) { _ in
                    self?.router.showTabBar()
                }
            }
        }
    }
}
