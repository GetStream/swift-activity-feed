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
    public typealias Completion<T: ActivityLikable> = (_ result: Result<(activity: T, button: UIButton), ClientError>) -> Void
    public typealias ErrorCompletion = (_ error: Error?) -> Void
    
    open func react<T: ActivityLikable>(with presenter: ReactionPresenterProtocol,
                                        activity: T,
                                        reaction: UserReaction?,
                                        kindOf kind: ReactionKind,
                                        targetsFeedIds: [FeedId] = [],
                                        _ completion: @escaping Completion<T>) {
        if isSelected {
            isEnabled = false
            if let reaction = reaction {
                presenter.remove(reaction: reaction, activity: activity.originalActivity) { [weak self] in
                    self?.parse($0, isSelected: false, completion)
                }
            } else {
                isSelected = false
            }
        } else {
            isEnabled = false
            presenter.addReaction(for: activity.originalActivity, kindOf: kind, targetsFeedIds: targetsFeedIds) { [weak self] in
                self?.parse($0, isSelected: true, completion)
            }
        }
    }
    
    private func parse<T: ActivityLikable>(_ result: Result<T, ClientError>,
                                           isSelected: Bool,
                                           _ completion: @escaping Completion<T>) {
        isEnabled = true
        
        if let activity = try? result.get() {
            self.isSelected = isSelected
            completion(.success((activity, self)))
        } else if let error = result.error {
            completion(.failure(error))
        }
    }
}
