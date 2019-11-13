//
//  ActivityObject.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 22/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import GetStream

/// An activity object protocol.
public protocol ActivityObjectProtocol: Enrichable {
    var text: String? { get }
    var imageURL: URL? { get }
}

/// An activity object with several subtypes: text, image, reposted activity, following user.
public enum ActivityObject: ActivityObjectProtocol {
    case unknown
    case text(_ value: String)
    case image(_ url: URL)
    case repost(_ activity: Activity)
    case following(_ user: User)
    
    public var referenceId: String {
        switch self {
        case .unknown:
            return ""
        case .text(let value):
            return value
        case .image(let url):
            return url.absoluteString
        case .repost(let activity):
            return activity.referenceId
        case .following(let user):
            return user.referenceId
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .unknown:
            throw ActivityObjectError.unkownValue
        case .text(let value):
            try container.encode(value)
        case .image(let url):
            try container.encode(url)
        case .repost(let activity):
            try container.encode(activity)
        case .following(let user):
            try container.encode(user)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let text = try? container.decode(String.self) {
            if text.hasPrefix("http"), let imageURL = URL(string: text) {
                self = .image(imageURL)
            } else {
                self = .text(text)
            }
        } else if let activity = try? container.decode(Activity.self) {
            self = .repost(activity)
        } else {
            let safeUser = try container.decode(MissingReference<User>.self)
            
            if safeUser.decodingError == nil {
                self = .following(safeUser.value)
            } else {
                self = .unknown
            }
        }
    }
    
    public var isMissedReference: Bool {
        return text == "!missed_reference"
    }
    
    public static func missed() -> ActivityObject {
        return .text("!missed_reference")
    }
}

extension ActivityObject {
    
    /// A text, if the object contains the text.
    public var text: String? {
        if case .text(let value) = self {
            return value
        }
        
        return nil
    }
    
    /// An image URL, if the object contains the image URL.
    public var imageURL: URL? {
        if case .image(let url) = self {
            return url
        }
        
        return nil
    }
}

public enum ActivityObjectError: String, Error {
    case unkownValue
}
