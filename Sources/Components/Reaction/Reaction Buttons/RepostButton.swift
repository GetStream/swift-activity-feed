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
    open func react<T: ActivityLikable>(with presenter: ReactionPresenterProtocol,
                                        activity: T,
                                        targetsFeedIds: [FeedId],
                                        _ completion: @escaping ErrorCompletion) {
        super.react(with: presenter,
                    activity: activity,
                    reaction: activity.repostReaction,
                    parentReaction: nil,
                    kindOf: .repost,
                    targetsFeedIds: targetsFeedIds) {
                        if let result = try? $0.get() {
                            result.button.setTitle(String(result.activity.repostsCount), for: .normal)
                            completion(nil)
                        } else {
                            completion($0.error)
                        }
        }
    }
}
