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
    
    public func addReaction<T: ActivityProtocol>(for activity: T,
                                                 kindOf kind: ReactionKind,
                                                 parentReaction: T.ReactionType? = nil,
                                                 targetsFeedIds: [FeedId],
                                                 _ completion: @escaping Completion<T>) {
        Client.shared.add(reactionTo: activity.id,
                          parentReactionId: parentReaction?.id,
                          kindOf: kind,
                          extraData: ReactionExtraData.empty,
                          userTypeOf: User.self) {
                            self.parse($0, for: activity, parentReaction, completion)
        }
    }
    
    public func addComment<T: ActivityProtocol>(for activity: T,
                                                text: String,
                                                parentReaction: T.ReactionType? = nil,
                                                _ completion: @escaping Completion<T>) {
        Client.shared.add(reactionTo: activity.id,
                          parentReactionId: parentReaction?.id,
                          kindOf: .comment,
                          extraData: ReactionExtraData.comment(text),
                          userTypeOf: User.self) {
                            self.parse($0, for: activity, parentReaction, completion)
        }
    }
    
    private func parse<T: ActivityProtocol>(_ result: Result<T.ReactionType, ClientError>,
                                            for activity: T,
                                            _ parentReaction: T.ReactionType?,
                                            _ completion: @escaping Completion<T>) {
        if let reaction = try? result.get() {
            var activity = activity
            
            if let parentReaction = parentReaction {
                var parentReaction = parentReaction
                parentReaction.addUserOwnChild(reaction)
            } else {
                activity.addUserOwnReaction(reaction)
            }
            
            completion(.success(activity))
            
        } else if let error = result.error {
            completion(.failure(error))
        }
    }
    
    public func remove<T: ActivityProtocol>(reaction: T.ReactionType, activity: T, _ completion: @escaping Completion<T>) {
        Client.shared.delete(reactionId: reaction.id) {
            if $0.error == nil {
                var activity = activity
                activity.removeUserOwnReaction(reaction)
                completion(.success(activity))
            } else if let error = $0.error {
                completion(.failure(error))
            }
        }
    }
    
    public func remove<T: ReactionProtocol>(reaction: T,
                                            parentReaction: T,
                                            _ completion: @escaping (_ result: Result<T, ClientError>) -> Void) {
        Client.shared.delete(reactionId: reaction.id) {
            if let error = $0.error {
                completion(.failure(error))
            } else {
                var parentReaction = parentReaction
                parentReaction.removeUserOwnChild(reaction)
                completion(.success(parentReaction))
            }
        }
    }
}
