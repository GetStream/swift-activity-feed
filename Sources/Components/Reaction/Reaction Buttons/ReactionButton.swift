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
    
    open func react<T: ActivityProtocol, U: UserProtocol>(with presenter: ReactionPresenterProtocol,
                                                          activity: T,
                                                          reaction: T.ReactionType?,
                                                          parentReaction: T.ReactionType?,
                                                          kindOf kind: ReactionKind,
                                                          targetsFeedIds: [FeedId] = [],
                                                          _ completion: @escaping Completion<T>)
        where T.ReactionType == GetStream.Reaction<ReactionExtraData, U> {
            if isSelected {
            isEnabled = false
            
            if let reaction = reaction {
                if let parentReaction = parentReaction {
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
                } else {
                    presenter.remove(reaction: reaction, activity: activity.original) { [weak self] in
                        self?.parse($0, isSelected: false, completion)
                    }
                }
            } else {
                isSelected = false
            }
        } else {
            isEnabled = false
            presenter.addReaction(for: activity.original,
                                  kindOf: kind,
                                  parentReaction: parentReaction,
                                  targetsFeedIds: targetsFeedIds,
                                  extraData: ReactionExtraData.empty,
                                  userTypeOf: U.self) { [weak self] in
                                    self?.parse($0, isSelected: true, completion)
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
