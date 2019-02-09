//
//  ReactionExtraData.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 09/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import GetStream

public enum ReactionExtraData: ReactionExtraDataProtocol {
    case empty
    case comment(_ text: String)
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .empty:
            try EmptyReactionExtraData.shared.encode(to: encoder)
        case .comment(let comment):
            try Comment(text: comment).encode(to: encoder)
        }
    }
    
    public init(from decoder: Decoder) throws {
        if let comment = try? Comment(from: decoder) {
            self = .comment(comment.text)
        } else {
            self = .empty
        }
    }
}
