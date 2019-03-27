//
//  ReactionButton.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 24/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import GetStream
import Result

/// A base class for reaction buttons.
open class ReactionButton: UIButton {
    public typealias Completion<T: ActivityProtocol> = (_ result: Result<(activity: T, button: UIButton), ClientError>) -> Void
    public typealias ErrorCompletion = (_ error: Error?) -> Void
    
    /// Add a reaction to an activity.
    open func react<T: ActivityProtocol, U: UserProtocol>(with presenter: ReactionPresenterProtocol,
                                                          activity: T,
                                                          reaction: T.ReactionType?,
                                                          parentReaction: T.ReactionType?,
                                                          kindOf kind: ReactionKind,
                                                          userTypeOf userType: U.Type,
                                                          targetsFeedIds: [FeedId] = [],
                                                          _ completion: @escaping Completion<T>)
        where T.ReactionType == GetStream.Reaction<ReactionExtraData, U> {
            isEnabled = false
            
            guard isSelected else {
                presenter.addReaction(for: activity,
                                      kindOf: kind,
                                      parentReaction: parentReaction,
                                      targetsFeedIds: targetsFeedIds,
                                      extraData: ReactionExtraData.empty,
                                      userTypeOf: userType) { [weak self] in
                                        self?.parse($0, isSelected: true, completion)
                }
                
                return
            }
            
            guard let reaction = reaction else {
                isSelected = false
                return
            }
            
            guard let parentReaction = parentReaction else {
                presenter.remove(reaction: reaction, activity: activity) { [weak self] in
                    self?.parse($0, isSelected: false, completion)
                }
                
                return
            }
            
            presenter.remove(reaction: reaction, parentReaction: parentReaction) { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.isEnabled = true
                
                if let error = $0.error {
                    completion(.failure(error))
                } else {
                    self.isSelected = false
                    completion(.success((activity, self)))
                }
            }
    }
    
    private func parse<T: ActivityProtocol>(_ result: Result<T, ClientError>,
                                            isSelected: Bool,
                                            _ completion: @escaping Completion<T>) where T.ReactionType: ReactionProtocol {
        isEnabled = true
        
        if let activity = try? result.get() {
            self.isSelected = isSelected
            completion(.success((activity, self)))
        } else if let error = result.error {
            completion(.failure(error))
        }
    }
}
