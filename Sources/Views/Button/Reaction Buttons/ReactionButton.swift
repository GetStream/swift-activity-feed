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
    public var presenter: ReactionPresenterProtocol?
    public typealias Completion<T: EnhancedActivity> = (_ result: Result<(activity: T, button: UIButton), ClientError>) -> Void
    public typealias ErrorCompletion = (_ error: Error?) -> Void
    
    open func setup<T: EnhancedActivity>(activity: T,
                                         reaction: Reaction<ReactionNoExtraData>?,
                                         kindOf kind: ReactionKind,
                                         targetsFeedIds: [FeedId] = [],
                                         _ completion: @escaping Completion<T>) {
        if isSelected {
            remove(reaction: reaction, activity: activity, completion)
        } else {
            addReaction(for: activity, kindOf: kind, targetsFeedIds: targetsFeedIds, completion)
        }
    }
    
    private func addReaction<T: EnhancedActivity>(for activity: T,
                                                  kindOf kind: ReactionKind,
                                                  targetsFeedIds: [FeedId] = [],
                                                  _ completion: @escaping Completion<T>) {
        if isSelected {
            return
        }
        
        guard let presenter = presenter else {
            print("⚠️", #function, "ReactionPresenter is empty")
            return
        }
        
        isEnabled = false
        
        presenter.addReaction(for: activity.originalActivity,
                              kindOf: kind,
                              targetsFeedIds: targetsFeedIds) { [weak self] in self?.parse($0, isSelected: true, completion) }
    }
    
    private func remove<T: EnhancedActivity>(reaction: Reaction<ReactionNoExtraData>?,
                                             activity: T,
                                             _ completion: @escaping Completion<T>) {
        guard isSelected, let reaction = reaction else {
            isSelected = false
            return
        }
        
        guard let presenter = presenter else {
            print("⚠️", #function, "ReactionPresenter is empty")
            return
        }
        
        isEnabled = false
        
        presenter.remove(reaction: reaction, activity: activity.originalActivity) { [weak self] in
            self?.parse($0, isSelected: false, completion)
        }
    }
    
    private func parse<T: EnhancedActivity>(_ result: Result<T, ClientError>,
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
