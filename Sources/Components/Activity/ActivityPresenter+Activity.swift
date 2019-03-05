//
//  ActivityPresenter+Activity.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 01/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import GetStream

extension ActivityPresenter where T: (ActivityProtocol & AttachmentPresentable) {
    
    public var ogData: OGResponse? {
        return activity.original.attachment?.openGraphData
    }
    
    public func attachmentImageURLs(withObjectImage: Bool = false) -> [URL]? {
        let originalActivity = activity.original
        
        if let imageURLs = originalActivity.attachment?.imageURLs, imageURLs.count > 0 {
            return imageURLs
        }
        
        return nil
    }
    
    public var cellsCount: Int {
        var count = 3
        
        if attachmentImageURLs() != nil {
            count += 1
        }
        
        if ogData != nil {
            count += 1
        }
        
        return count
    }
}

// MARK: - Reactions

extension ActivityPresenter where T: ActivityProtocol,
                                  T.ReactionType: ReactionProtocol,
                                  T.ReactionType.UserType: (UserNamePresentable & AvatarPresentable) {
    
    func reactionTitle(kindOf reactionKind: ReactionKind, suffix: String) -> String? {
        guard let reactions = activity.original.latestReactions?[reactionKind],
            let count: Int = activity.original.reactionCounts?[reactionKind],
            let first = reactions.first else {
            return nil
        }
        
        if count == 1 {
            return "\(first.user.name) \(suffix)"
        }
        
        return "\(first.user.name) and \(count - 1) others \(suffix)"
    }
    
    func reactionUserAvatarURLs(kindOf reactionKind: ReactionKind) -> [URL] {
        guard let reactions = activity.original.latestReactions?[reactionKind] else {
            return []
        }
        
        return reactions.map { $0.user.avatarURL }.compactMap { $0 }
    }
    
    func comment(at index: Int) -> T.ReactionType? {
        guard let reactions = activity.original.latestReactions?[.comment] else {
            return nil
        }
        
        return index < reactions.count ? reactions[index] : reactions.first
    }
}
