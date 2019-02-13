//
//  LikeButton.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 24/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import GetStream

open class LikeButton: ReactionButton {
    open func react<T: ActivityLikable>(with presenter: ReactionPresenterProtocol,
                                        activity: T,
                                        reaction: T.ReactionType? = nil,
                                        parentReaction: T.ReactionType? = nil,
                                        _ completion: @escaping ErrorCompletion) {
        super.react(with: presenter,
                    activity: activity,
                    reaction: reaction ?? activity.likedReaction,
                    parentReaction: parentReaction,
                    kindOf: .like) {
            if let result = try? $0.get() {
                let title: String
                
                if let parentReaction = parentReaction {
                    let count = parentReaction.childrenCounts[.like] ?? 0
                    title = count > 0 ? String(count) : ""
                } else {
                    title = result.activity.likesCount > 0 ? String(result.activity.likesCount) : ""
                }
                
                result.button.setTitle(title, for: .normal)
                completion(nil)
            } else {
                completion($0.error)
            }
        }
    }
}
