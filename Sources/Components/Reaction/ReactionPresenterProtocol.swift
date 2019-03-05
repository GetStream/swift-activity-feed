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
    typealias Completion<T: ActivityProtocol> = (_ result: Result<T, ClientError>) -> Void
    
    func addReaction<T: ActivityProtocol,
        E: ReactionExtraDataProtocol,
        U: UserProtocol>(for activity: T,
                         kindOf kind: ReactionKind,
                         parentReaction: GetStream.Reaction<E, U>?,
                         targetsFeedIds: [FeedId],
                         extraData: E,
                         userTypeOf userType: U.Type,
                         _ completion: @escaping Completion<T>) where T.ReactionType == GetStream.Reaction<E, U>
    
    func addComment<T: ActivityProtocol,
        E: ReactionExtraDataProtocol,
        U: UserProtocol>(for activity: T,
                         parentReaction: T.ReactionType?,
                         extraData: E,
                         userTypeOf userType: U.Type,
                         _ completion: @escaping Completion<T>) where T.ReactionType == GetStream.Reaction<E, U>
    
    func remove<T: ActivityProtocol>(reaction: T.ReactionType,
                                     activity: T,
                                     _ completion: @escaping Completion<T>) where T.ReactionType: ReactionProtocol
    
    func remove<T: ReactionProtocol>(reaction: T,
                                     parentReaction: T,
                                     _ completion: @escaping (_ result: Result<T, ClientError>) -> Void)
}
