//
//  LikeButton.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 24/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

open class LikeButton: ReactionButton {
    open func react<T: EnhancedActivity>(with presenter: ReactionPresenterProtocol,
                                         activity: T,
                                         _ completion: @escaping ErrorCompletion) {
        super.react(with: presenter, activity: activity, reaction: activity.likedReaction, kindOf: .like) {
            if let result = try? $0.get() {
                result.button.setTitle(String(result.activity.likesCount), for: .normal)
                completion(nil)
            } else {
                completion($0.error)
            }
        }
    }
}
