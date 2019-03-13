//
//  AttachmentPresentable.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 05/03/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import GetStream

public protocol AttachmentRepresentable {
    var attachment: ActivityAttachment? { get }
}

extension AttachmentRepresentable {
    
    public var ogData: OGResponse? {
        return attachment?.openGraphData
    }
    
    public func attachmentImageURLs() -> [URL]? {
        if let imageURLs = attachment?.imageURLs, imageURLs.count > 0 {
            return imageURLs
        }
        
        return nil
    }
}
