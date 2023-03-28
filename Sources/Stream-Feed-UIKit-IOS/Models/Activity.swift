//
//  CustomActivity.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 17/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import GetStream

/// A reaction with `ReactionExtraData` and `User`. See `ReactionExtraData`, `User`.
public typealias Reaction = GetStream.Reaction<ReactionExtraData, User>

/// An enriched activity with `User` type, `ActivityObject` as object type and `Reaction` as reation type.
/// It has additional properties: text and attachment. See `AttachmentRepresentable`.
public final class Activity: EnrichedActivity<User, ActivityObject, Reaction>, TextRepresentable, AttachmentRepresentable {
    
    private enum CodingKeys: String, CodingKey {
        case text
        case attachments
    }
    
    public var text: String?
    public var attachment: ActivityAttachment?
    
    public var original: Activity {
        switch object {
        case .repost(let activity):
            return activity
        default:
            return self
        }
    }
    
    public init(actor: User, verb: Verb, object: ActivityObject, feedIds: FeedIds? = nil) {
        super.init(actor: actor, verb: verb, object: object, feedIds: feedIds)
    }

    required public init(actor: User,
                         verb: Verb,
                         object: ActivityObject,
                         foreignId: String? = nil,
                         time: Date? = nil,
                         feedIds: FeedIds? = nil,
                         originFeedId: FeedId? = nil) {
        super.init(actor: actor, verb: verb, object: object, feedIds: feedIds)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        attachment = try container.decodeIfPresent(ActivityAttachment.self, forKey: .attachments)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encodeIfPresent(attachment, forKey: .attachments)
        try super.encode(to: encoder)
    }
}
