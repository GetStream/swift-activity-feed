//
//  CustomActivity.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 17/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import GetStream

public typealias UserReaction = Reaction<EmptyReactionExtraData, User>

public final class Activity: EnrichedActivity<User, ActivityObject, String, UserReaction>, ActivityLikable {
    
    private enum CodingKeys: String, CodingKey {
        case text
        case attachments
    }
    
    var text: String?
    var attachment: ActivityAttachment?
    
    public var originalActivity: Activity {
        if case .repost(let originalActivity) = object {
            return originalActivity
        }
        
        return self
    }
    
    public init(actor: User, verb: Verb, object: ActivityObject, target: TargetType? = nil, feedIds: FeedIds? = nil) {
        super.init(actor: actor, verb: verb, object: object, target: target, feedIds: feedIds)
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        attachment = try container.decodeIfPresent(ActivityAttachment.self, forKey: .attachments)
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encodeIfPresent(attachment, forKey: .attachments)
        try super.encode(to: encoder)
    }
}

// MARK: - Reactions

extension Activity {
    public var isLiked: Bool {
        return (ownReactions?[.like]?.count ?? 0) > 0
    }
    
    public var likedReaction: UserReaction? {
        return ownReactions?[.like]?.first
    }
    
    public var likesCount: Int {
        return reactionCounts?[.like] ?? 0
    }
    
    public var repostsCount: Int {
        return reactionCounts?[.repost] ?? 0
    }
    
    public var repostReaction: UserReaction? {
        return originalActivity.ownReactions?[.repost]?.first
    }
    
    public var isReposted: Bool {
        return (ownReactions?[.repost]?.count ?? 0) > 0
    }
    
    public var commentsCount: Int {
        return reactionCounts?[.comment] ?? 0
    }
}

// MARK: - Activity Attachment

final class ActivityAttachment: Codable {
    private enum CodingKeys: String, CodingKey {
        case imageURLs = "images"
        case openGraphData = "og"
        case files
    }
    
    var imageURLs: [URL]?
    var openGraphData: OGResponse?
    var files: [ActivityAttachmentFile]?
}

// MARK: - Activity Attachment File

final class ActivityAttachmentFile: Codable {
    var name: String
    var url: URL
    var mimeType: String
}
