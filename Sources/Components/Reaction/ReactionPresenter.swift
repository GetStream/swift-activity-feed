//
//  ReactionPresenter.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 25/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import GetStream
import Result

/// A reaction presenter.
open class ReactionPresenter: ReactionPresenterProtocol {
    
    /// Add a reaction to an activity.
    public func addReaction<T: ActivityProtocol,
        E: ReactionExtraDataProtocol,
        U: UserProtocol>(for activity: T,
                         kindOf kind: ReactionKind,
                         parentReaction: GetStream.Reaction<E, U>? = nil,
                         targetsFeedIds: [FeedId],
                         extraData: E,
                         userTypeOf userType: U.Type,
                         _ completion: @escaping Completion<T>) where T.ReactionType == GetStream.Reaction<E, U> {
        Client.shared.add(reactionTo: activity.id,
                          parentReactionId: parentReaction?.id,
                          kindOf: kind,
                          extraData: extraData,
                          userTypeOf: userType,
                          targetsFeedIds: targetsFeedIds) {
                            self.parse($0, for: activity, parentReaction, completion)
        }
    }
    
    /// Add a comment to an activity.
    public func addComment<T: ActivityProtocol,
        E: ReactionExtraDataProtocol,
        U: UserProtocol>(for activity: T,
                         parentReaction: T.ReactionType? = nil,
                         extraData: E,
                         userTypeOf userType: U.Type,
                         _ completion: @escaping Completion<T>) where T.ReactionType == GetStream.Reaction<E, U> {
        Client.shared.add(reactionTo: activity.id,
                          parentReactionId: parentReaction?.id,
                          kindOf: .comment,
                          extraData: extraData,
                          userTypeOf: userType) {
                            self.parse($0, for: activity, parentReaction, completion)
        }
    }
    
    private func parse<T: ActivityProtocol>(_ result: Result<T.ReactionType, ClientError>,
                                            for activity: T,
                                            _ parentReaction: T.ReactionType?,
                                            _ completion: @escaping Completion<T>) where T.ReactionType: ReactionProtocol {
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
    
    /// Remove a reaction from an activity.
    public func remove<T: ActivityProtocol>(reaction: T.ReactionType, activity: T, _ completion: @escaping Completion<T>)
        where T.ReactionType: ReactionProtocol {
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
    
    /// Remove a reaction from a parent reaction.
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
