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
                                         parentReaction: Reaction?,
                                         targetsFeedIds: [FeedId],
                                         _ completion: @escaping Completion<T>)
    
    func addComment<T: ActivityLikable>(for activity: T,
                                        text: String,
                                        parentReaction: Reaction?,
                                        _ completion: @escaping Completion<T>)
    
    func remove<T: ActivityLikable>(reaction: Reaction, activity: T, _ completion: @escaping Completion<T>)
    
    func remove(reaction: Reaction,
                parentReaction: Reaction,
                _ completion: @escaping (_ result: Result<Reaction, ClientError>) -> Void)
}
