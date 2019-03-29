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

/// Activity Presenter reaction types.
public struct ActivityPresenterReactionTypes: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// A comments reaction type.
    public static let comments = ActivityPresenterReactionTypes(rawValue: 1 << 0)
    /// A likes reaction type.
    public static let likes = ActivityPresenterReactionTypes(rawValue: 1 << 1)
    /// A reposts reaction type.
    public static let reposts = ActivityPresenterReactionTypes(rawValue: 1 << 2)
}

// MARK: - Activity Presenter

/// Activity Presenter for the managing events for the activity.
public struct ActivityPresenter<T: ActivityProtocol> {
    /// An activity. See `ActivityProtocol`.
    public let activity: T
    /// A reaction presenter for the handling reactions. See `ReactionPresenter`.
    public let reactionPresenter: ReactionPresenter
    /// Reaction types for the handling.
    public var reactionTypes: ActivityPresenterReactionTypes = []
    
    /// An original activity, if the object is type of `ActivityObject`.
    /// If the activity is a result of a repost, this property will contains the original activity.
    public var originalActivity: T {
        if let object = activity.object as? ActivityObject,
            case .repost(let repostedActivity) = object,
            let activity = repostedActivity as? T {
            return activity
        }
        
        return activity
    }
    
    /// An attachment of the original activity. See `AttachmentRepresentable`.
    public var originalActivityAttachment: AttachmentRepresentable? {
        return originalActivity as? AttachmentRepresentable
    }
    
    /// Creates an activity presenter for an activity with a reaction presenter.
    public init(activity: T, reactionPresenter: ReactionPresenter, reactionTypes: ActivityPresenterReactionTypes = []) {
        self.activity = activity
        self.reactionPresenter = reactionPresenter
        self.reactionTypes = reactionTypes
    }
    
    /// Creates a reaction paginator based on the activity id and a reaction kind.
    public func reactionPaginator<E: ReactionExtraDataProtocol,
        U: UserProtocol>(activityId: String, reactionKind: ReactionKind) -> ReactionPaginator<E, U>
        where T.ReactionType == GetStream.Reaction<E, U> {
            return ReactionPaginator(activityId: activityId, reactionKind: reactionKind)
    }
}

// MARK: - Activity Presenter for Table View

/// Activity Presenter table view cells data
public enum ActivityPresenterCellType {
    case activity
    case attachmentImages(_ urls: [URL])
    case attachmentOpenGraphData(_ ogData: OGResponse)
    case actions
    case separator
}

extension ActivityPresenter {
    
    /// A number of cells in the activity section.
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
    
    /// Returns the type of the cell at a row.
    public func cellType(at row: Int) -> ActivityPresenterCellType? {
        let cellsCount = self.cellsCount
        let reactionsCellCount = withReactions ? 1 : 0
        
        switch row {
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
    
    /// Check if activity table view section needs to show with reactions.
    public var withReactions: Bool {
        return reactionTypes != []
    }
}

// MARK: - Reactions

extension ActivityPresenter where T: ActivityProtocol,
                                  T.ReactionType: ReactionProtocol,
                                  T.ReactionType.UserType: (UserNameRepresentable & AvatarRepresentable) {
    
    /// Return a title for the activity reaction of a reaction kind.
    public func reactionTitle(for activity: T, kindOf reactionKind: ReactionKind, suffix: String) -> String? {
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
    
    /// Returns a list of avatar URL's for the activity reactions of a reaction kind.
    public func reactionUserAvatarURLs(for activity: T, kindOf reactionKind: ReactionKind) -> [URL] {
        guard let reactions = activity.latestReactions?[reactionKind] else {
            return []
        }
        
        return reactions.map { $0.user.avatarURL }.compactMap { $0 }
    }
    
    /// Returns a comment for the activity at an index.
    public func comment(for activity: T, at index: Int) -> T.ReactionType? {
        guard let reactions = activity.latestReactions?[.comment] else {
            return nil
        }
        
        return index < reactions.count ? reactions[index] : reactions.first
    }
}
