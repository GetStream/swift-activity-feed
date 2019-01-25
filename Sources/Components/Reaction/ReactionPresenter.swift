//
//  ReactionPresenter.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 25/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import GetStream
import Result

open class ReactionPresenter: ReactionPresenterProtocol {
    
    let client: Client
    
    init(client: Client) {
        self.client = client
    }
    
    public func addReaction<T: EnhancedActivity>(for activity: T,
                                                 kindOf kind: ReactionKind,
                                                 targetsFeedIds: [FeedId],
                                                 _ completion: @escaping (Result<T, ClientError>) -> Void) {
        client.add(reactionTo: activity.id, kindOf: kind, targetsFeedIds: targetsFeedIds) { result in
            if let reaction = try? result.get() {
                var activity = activity
                activity.addOwnReaction(reaction)
                completion(.success(activity))
                
            } else if let error = result.error {
                completion(.failure(error))
            }
        }
    }
    
    public func remove<T: EnhancedActivity>(reaction: Reaction<ReactionNoExtraData>,
                                            activity: T,
                                            _ completion: @escaping (Result<T, ClientError>) -> Void) {
        client.delete(reactionId: reaction.id) { result in
            if result.error == nil {
                var activity = activity
                activity.deleteOwnReaction(reaction)
                completion(.success(activity))
                
            } else if let error = result.error {
                completion(.failure(error))
            }
        }
    }
}
