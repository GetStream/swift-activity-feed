//
//  RepostButton.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 24/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import GetStream

open class RepostButton: ReactionButton {
    
    public static func make(frame: CGRect = CGRect(x: 0, y: 0, width: 44, height: 44)) -> RepostButton {
        let button = RepostButton(frame: frame)
        button.setImage(.repostIcon, for: .normal)
        return button
    }
    
    open func repost<T: ActivityProtocol, U: UserProtocol>(_ activity: T,
                                                           presenter: ReactionPresenterProtocol,
                                                           targetsFeedIds: [FeedId] = [],
                                                           _ completion: @escaping ErrorCompletion)
        where T.ReactionType == GetStream.Reaction<ReactionExtraData, U> {
            react(with: presenter,
                  activity: activity.original,
                  reaction: activity.original.userRepostReaction,
                  parentReaction: nil,
                  kindOf: .repost,
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
