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
    
    var imageURLs: [URL]?
    var openGraphData: OGResponse?
    var files: [ActivityAttachmentFile]?
}

// MARK: - Activity Attachment File

public final class ActivityAttachmentFile: Codable {
    var name: String
    var url: URL
    var mimeType: String
}
