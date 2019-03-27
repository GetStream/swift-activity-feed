//
//  LikeButton.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 24/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import GetStream

/// A like button.
open class LikeButton: ReactionButton {
    
    /// Creates an instance of the like button.
    public static func make(frame: CGRect = CGRect(x: 0, y: 0, width: 44, height: 44)) -> LikeButton {
        let button = LikeButton(frame: frame)
        button.setImage(.likeInactiveIcon, for: .normal)
        button.setImage(.likeInactiveIcon, for: .disabled)
        button.setImage(.likeIcon, for: .highlighted)
        button.setImage(.likeIcon, for: .selected)
        return button
    }
    
    /// Likes an activity.
    open func like<T: ActivityProtocol, U: UserProtocol>(_ activity: T,
                                                         presenter: ReactionPresenterProtocol,
                                                         likedReaction: T.ReactionType? = nil,
                                                         parentReaction: T.ReactionType? = nil,
                                                         userTypeOf userType: U.Type,
                                                         _ completion: @escaping ErrorCompletion)
        where T.ReactionType == GetStream.Reaction<ReactionExtraData, U> {
            react(with: presenter,
                  activity: activity.original,
                  reaction: likedReaction ?? activity.original.userLikedReaction,
                  parentReaction: parentReaction,
                  kindOf: .like,
                  userTypeOf: T.ReactionType.UserType.self) {
                    if let result = try? $0.get() {
                        let title: String
                        
                        if let parentReaction = parentReaction {
                            let count = parentReaction.childrenCounts[.like] ?? 0
                            title = count > 0 ? String(count) : ""
                        } else {
                            let count = result.activity.original.likesCount
                            title = count > 0 ? String(count) : ""
                        }
                        
                        result.button.setTitle(title, for: .normal)
                        completion(nil)
                    } else {
                        completion($0.error)
                    }
            }
    }
}
