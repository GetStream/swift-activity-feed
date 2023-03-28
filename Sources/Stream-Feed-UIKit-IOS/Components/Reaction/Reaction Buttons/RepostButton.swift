//
//  RepostButton.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 24/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import GetStream

/// A repost button.
open class RepostButton: ReactionButton {
    
    /// Creates an instance of the repost button.
    public static func make(frame: CGRect = CGRect(x: 0, y: 0, width: 44, height: 44)) -> RepostButton {
        let button = RepostButton(frame: frame)
        button.setImage(.repostIcon, for: .normal)
        return button
    }
    
    /// Reposts an activity.
    open func repost<T: ActivityProtocol, U: UserProtocol>(_ activity: T,
                                                           presenter: ReactionPresenterProtocol,
                                                           userTypeOf userType: U.Type,
                                                           targetsFeedIds: [FeedId] = [],
                                                           _ completion: @escaping ErrorCompletion)
        where T.ReactionType == GetStream.Reaction<ReactionExtraData, U> {
            react(with: presenter,
                  activity: activity.original,
                  reaction: activity.original.userRepostReaction,
                  parentReaction: nil,
                  kindOf: .repost,
                  userTypeOf: U.self,
                  targetsFeedIds: targetsFeedIds) {
                    if let result = try? $0.get() {
                        result.button.setTitle(String(result.activity.original.repostsCount), for: .normal)
                        completion(nil)
                    } else {
                        completion($0.error)
                    }
            }
    }
}
