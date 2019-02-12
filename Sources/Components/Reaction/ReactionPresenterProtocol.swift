//
//  ReactionPresenter.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 24/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Result
import GetStream

public protocol ReactionPresenterProtocol {
    typealias Completion<T: ActivityLikable> = (_ result: Result<T, ClientError>) -> Void
    
    func addReaction<T: ActivityLikable>(for activity: T,
                                         kindOf kind: ReactionKind,
                                         parentReactionId: String?,
                                         targetsFeedIds: [FeedId],
                                         _ completion: @escaping Completion<T>)
    
    func addComment<T: ActivityLikable>(for activity: T,
                                        text: String,
                                        parentReactionId: String?,
                                        _ completion: @escaping Completion<T>)
    
    func remove<T: ActivityLikable>(reaction: UserReaction, activity: T, _ completion: @escaping Completion<T>)
}
