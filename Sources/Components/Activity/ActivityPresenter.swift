//
//  ActivityPresenter.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 01/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import GetStream

public struct ActivityPresenter<T: ActivityProtocol> {
    public let activity: T
    public let reactionPresenter: ReactionPresenter
    
    public var originalActivity: T {
        if let object = activity.object as? ActivityObject,
            case .repost(let repostedActivity) = object,
            let activity = repostedActivity as? T {
            return activity
        }
        
        return activity
    }
    
    public func reactionPaginator<E: ReactionExtraDataProtocol,
                                  U: UserProtocol>(activityId: String, reactionKind: ReactionKind) -> ReactionPaginator<E, U>
        where T.ReactionType == GetStream.Reaction<E, U> {
            return ReactionPaginator(activityId: activityId, reactionKind: reactionKind)
    }
}

extension ActivityPresenter {
    public var cellsCount: Int {
        var count = 3
        
        if let activity = originalActivity as? AttachmentRepresentable {
            if activity.attachmentImageURLs() != nil {
                count += 1
            }
            
            if activity.ogData != nil {
                count += 1
            }
        }
        
        return count
    }
}

// MARK: - Reactions

extension ActivityPresenter where T: ActivityProtocol,
                                  T.ReactionType: ReactionProtocol,
                                  T.ReactionType.UserType: (UserNameRepresentable & AvatarRepresentable) {
    
    func reactionTitle(for activity: T, kindOf reactionKind: ReactionKind, suffix: String) -> String? {
        guard let reactions = activity.latestReactions?[reactionKind],
            let count: Int = activity.reactionCounts?[reactionKind],
            let first = reactions.first else {
                return nil
        }
        
        if count == 1 {
            return "\(first.user.name) \(suffix)"
        }
        
        return "\(first.user.name) and \(count - 1) others \(suffix)"
    }
    
    func reactionUserAvatarURLs(for activity: T, kindOf reactionKind: ReactionKind) -> [URL] {
        guard let reactions = activity.latestReactions?[reactionKind] else {
            return []
        }
        
        return reactions.map { $0.user.avatarURL }.compactMap { $0 }
    }
    
    func comment(for activity: T, at index: Int) -> T.ReactionType? {
        guard let reactions = activity.latestReactions?[.comment] else {
            return nil
        }
        
        return index < reactions.count ? reactions[index] : reactions.first
    }
}
