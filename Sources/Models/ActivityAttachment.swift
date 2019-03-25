//
//  ActivityAttachment.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 05/03/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import GetStream

public final class ActivityAttachment: Codable {
    private enum CodingKeys: String, CodingKey {
        case imageURLs = "images"
        case openGraphData = "og"
        case files
    }
    
    public static func make() -> ActivityAttachment {
        return ActivityAttachment()
    }
    
    public var imageURLs: [URL]?
    public var openGraphData: OGResponse?
    public var files: [ActivityAttachmentFile]?
}

// MARK: - Activity Attachment File

public final class ActivityAttachmentFile: Codable {
    public var name: String
    public var url: URL
    public var mimeType: String
}
