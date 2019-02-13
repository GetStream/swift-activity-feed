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
                                                parentReaction: Reaction? = nil,
                                                targetsFeedIds: [FeedId],
                                                _ completion: @escaping Completion<T>) {
        client.add(reactionTo: activity.id,
                   parentReactionId: parentReaction?.id,
                   kindOf: kind,
                   extraData: ReactionExtraData.empty,
                   userTypeOf: User.self) {
                    self.parse($0, for: activity, parentReaction, completion)
        }
    }
    
    public func addComment<T: ActivityLikable>(for activity: T,
                                               text: String,
                                               parentReaction: Reaction? = nil,
                                               _ completion: @escaping Completion<T>) {
        client.add(reactionTo: activity.id,
                   parentReactionId: parentReaction?.id,
                   kindOf: .comment,
                   extraData: ReactionExtraData.comment(text),
                   userTypeOf: User.self) {
                    self.parse($0, for: activity, parentReaction, completion)
        }
    }
    
    private func parse<T: ActivityLikable>(_ result: Result<T.ReactionType, ClientError>,
                                           for activity: T,
                                           _ parentReaction: Reaction?,
                                           _ completion: @escaping Completion<T>) {
        if let reaction = try? result.get() {
            var activity = activity
            
            if let parentReaction = parentReaction {
                parentReaction.addUserOwnChild(reaction)
            } else {
                activity.addUserOwnReaction(reaction)
            }
            
            completion(.success(activity))
            
        } else if let error = result.error {
            completion(.failure(error))
        }
    }
    
    public func remove<T: ActivityLikable>(reaction: T.ReactionType, activity: T, _ completion: @escaping Completion<T>) {
        client.delete(reactionId: reaction.id) {
            if $0.error == nil {
                var activity = activity
                activity.removeUserOwnReaction(reaction)
                completion(.success(activity))
            } else if let error = $0.error {
                completion(.failure(error))
            }
        }
    }
    
    public func remove(reaction: Reaction,
                       parentReaction: Reaction,
                       _ completion: @escaping (_ result: Result<Reaction, ClientError>) -> Void) {
        client.delete(reactionId: reaction.id) {
            if let error = $0.error {
                completion(.failure(error))
            } else {
                parentReaction.removeUserOwnChild(reaction)
                completion(.success(parentReaction))
            }
        }
    }
}
