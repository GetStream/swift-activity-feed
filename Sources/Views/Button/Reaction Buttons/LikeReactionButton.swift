//
//  LikeReactionButton.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 24/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

open class LikeReactionButton: ReactionButton {
    open func setup<T: EnhancedActivity>(presenter: ReactionPresenterProtocol, activity: T, _ completion: @escaping ErrorCompletion) {
        self.presenter = presenter
        
        super.setup(activity: activity, reaction: activity.likedReaction, kindOf: .like) {
            if let result = try? $0.get() {
                result.button.setTitle(String(result.activity.likesCount), for: .normal)
                completion(nil)
            } else {
                completion($0.error)
            }
        }
    }
}
