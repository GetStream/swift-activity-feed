//
//  ActivityObject.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 22/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import GetStream

enum ActivityObject: Enrichable {
    case text(_ value: String)
    case image(_ url: URL)
    case repost(_ activity: Activity)
    
    public var referenceId: String {
        switch self {
        case .text(let value):
            return value
        case .image(let url):
            return url.absoluteString
        case .repost(let activity):
            return activity.referenceId
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .text(let value):
            try container.encode(value)
        case .image(let url):
            try container.encode(url)
        case .repost(let activity):
            try container.encode(activity)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let text = try? container.decode(String.self) {
            if text.hasPrefix("http"), let imageURL = try? container.decode(URL.self) {
                self = .image(imageURL)
            } else {
                self = .text(text)
            }
        } else {
            self = .repost(try container.decode(Activity.self))
        }
    }
}
