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
}

// MARK: - Editing

extension ReactionPresenter {
    
    public func addReaction<T: ActivityLikable>(for activity: T,
                                                kindOf kind: ReactionKind,
                                                targetsFeedIds: [FeedId],
                                                _ completion: @escaping Completion<T>) {
        client.add(reactionTo: activity.id, kindOf: kind, extraData: ReactionExtraData.empty, userTypeOf: User.self) {
            self.parse($0, for: activity, completion)
        }
    }
    
    public func addComment<T: ActivityLikable>(for activity: T, text: String, _ completion: @escaping Completion<T>) {
        client.add(reactionTo: activity.id, kindOf: .comment, extraData: ReactionExtraData.comment(text), userTypeOf: User.self) {
            self.parse($0, for: activity, completion)
        }
    }
    
    private func parse<T: ActivityLikable>(_ result: Result<T.ReactionType, ClientError>,
                                           for activity: T,
                                           _ completion: @escaping Completion<T>) {
        if let reaction = try? result.get() {
            var activity = activity
            activity.addOwnReaction(reaction)
            completion(.success(activity))
        } else if let error = result.error {
            completion(.failure(error))
        }
    }
    
    public func remove<T: ActivityLikable>(reaction: UserReaction,
                                           activity: T,
                                           _ completion: @escaping Completion<T>) {
        client.delete(reactionId: reaction.id) {
            if $0.error == nil {
                var activity = activity
                activity.deleteOwnReaction(reaction)
                completion(.success(activity))
            } else if let error = $0.error {
                completion(.failure(error))
            }
        }
    }
}
