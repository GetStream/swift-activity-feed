//
//  ActivityAttachment.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 05/03/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import GetStream

/// An activity attachment with several values: images URl's, Open Graph data abd files. See `ActivityAttachmentFile`.
public final class ActivityAttachment: Codable {
    private enum CodingKeys: String, CodingKey {
        case imageURLs = "images"
        case openGraphData = "og"
        case files
    }
    
    /// Create an instance of an activity attachment.
    public static func make() -> ActivityAttachment {
        return ActivityAttachment()
    }
    
    /// A list of image URL's.
    public var imageURLs: [URL]?
    /// An Open Graph data. See `OGResponse`.
    public var openGraphData: OGResponse?
    /// A list of files. See `ActivityAttachmentFile`.
    public var files: [ActivityAttachmentFile]?
}

// MARK: - Activity Attachment File

public final class ActivityAttachmentFile: Codable {
    public var name: String
    public var url: URL
    public var mimeType: String
}
