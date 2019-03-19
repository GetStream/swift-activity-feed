//
//  ActivityPresenter.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 01/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import GetStream

// MARK: - Activity Presenter Reaction Types

public struct ActivityPresenterReactionTypes: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let comments = ActivityPresenterReactionTypes(rawValue: 1 << 0)
    public static let likes = ActivityPresenterReactionTypes(rawValue: 1 << 1)
    public static let reposts = ActivityPresenterReactionTypes(rawValue: 1 << 2)
}

// MARK: - Activity Presenter

public struct ActivityPresenter<T: ActivityProtocol> {
    public let activity: T
    public let reactionPresenter: ReactionPresenter
    public var reactionTypes: ActivityPresenterReactionTypes = []
    
    public var originalActivity: T {
        if let object = activity.object as? ActivityObject,
            case .repost(let repostedActivity) = object,
            let activity = repostedActivity as? T {
            return activity
        }
        
        return activity
    }
    
    public var originalActivityAttachment: AttachmentRepresentable? {
        return originalActivity as? AttachmentRepresentable
    }
    
    public init(activity: T, reactionPresenter: ReactionPresenter, reactionTypes: ActivityPresenterReactionTypes = []) {
        self.activity = activity
        self.reactionPresenter = reactionPresenter
        self.reactionTypes = reactionTypes
    }
    
    public func reactionPaginator<E: ReactionExtraDataProtocol,
        U: UserProtocol>(activityId: String, reactionKind: ReactionKind) -> ReactionPaginator<E, U>
        where T.ReactionType == GetStream.Reaction<E, U> {
            return ReactionPaginator(activityId: activityId, reactionKind: reactionKind)
    }
}

// MARK: - Table View Cells Data

public enum ActivityPresenterCellType {
    case activity
    case attachmentImages(_ urls: [URL])
    case attachmentOpenGraphData(_ ogData: OGResponse)
    case actions
    case separator
}

extension ActivityPresenter {
    
    public var cellsCount: Int {
        var count = 2 + (withReactions ? 1 : 0)
        
        if let originalActivityAttachment = originalActivityAttachment {
            if originalActivityAttachment.attachmentImageURLs() != nil {
                count += 1
            }
            
            if originalActivityAttachment.ogData != nil {
                count += 1
            }
        }
        
        return count
    }
    
    public func cellType(at indexPath: IndexPath) -> ActivityPresenterCellType? {
        let cellsCount = self.cellsCount
        let reactionsCellCount = withReactions ? 1 : 0
        
        switch indexPath.row {
        case 0:
            return .activity
        case (cellsCount - 3 - reactionsCellCount):
            if let urls = originalActivityAttachment?.attachmentImageURLs() {
                return .attachmentImages(urls)
            }
        case (cellsCount - 2 - reactionsCellCount):
            if let ogData = originalActivityAttachment?.ogData {
                return .attachmentOpenGraphData(ogData)
            }
            
            if let urls = originalActivityAttachment?.attachmentImageURLs() {
                return .attachmentImages(urls)
            }
        case (cellsCount - 2) where reactionsCellCount > 0:
            return .actions
        case (cellsCount - 1):
            return .separator
        default:
            break
        }
        
        return nil
    }
    
    public var withReactions: Bool {
        return reactionTypes != []
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
