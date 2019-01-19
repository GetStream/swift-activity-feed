//
//  CustomActivity.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 17/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import GetStream

public final class Activity: EnrichedActivity<User, String, String> {
    private enum CodingKeys: String, CodingKey {
        case text
        case attachments
    }
    
    var text: String?
    var attachments: CustomActivityAttachment?
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        attachments = try container.decodeIfPresent(CustomActivityAttachment.self, forKey: .attachments)
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encodeIfPresent(attachments, forKey: .attachments)
        try super.encode(to: encoder)
    }
}

final class CustomActivityAttachment: Codable {
    private enum CodingKeys: String, CodingKey {
        case imageURLs = "images"
        case openGraphData = "og"
        case files
    }
    
    var imageURLs: [URL]?
    var openGraphData: OGResponse?
    var files: [CustomActivityAttachmentFile]?
}

final class CustomActivityAttachmentFile: Codable {
    var name: String
    var url: URL
    var mimeType: String
}
