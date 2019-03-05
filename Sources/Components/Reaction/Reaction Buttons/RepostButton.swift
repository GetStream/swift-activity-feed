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
    open func react<T: ActivityProtocol, U: UserProtocol>(with presenter: ReactionPresenterProtocol,
                                        activity: T,
                                        targetsFeedIds: [FeedId],
                                        _ completion: @escaping ErrorCompletion)
        where T.ReactionType == GetStream.Reaction<ReactionExtraData, U> {
        super.react(with: presenter,
                    activity: activity,
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
