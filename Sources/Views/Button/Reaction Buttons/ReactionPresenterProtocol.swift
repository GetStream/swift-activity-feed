//
//  ReactionPresenter.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 24/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Result
import GetStream

public typealias EnhancedActivity = (ActivityRepostable & ActivityLikable)

public protocol ReactionPresenterProtocol {
    typealias Completion<T: EnhancedActivity> = (_ error: Result<T, ClientError>) -> Void
    
    func addReaction<T: EnhancedActivity>(for activity: T,
                                          kindOf kind: ReactionKind,
                                          targetsFeedIds: [FeedId],
                                          _ completion: @escaping Completion<T>)
    
    func remove<T: EnhancedActivity>(reaction: Reaction<ReactionNoExtraData>,
                                     activity: T,
                                     _ completion: @escaping Completion<T>)
}
