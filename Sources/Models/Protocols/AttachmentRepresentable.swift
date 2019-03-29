//
//  AttachmentPresentable.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 05/03/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import GetStream

/// An attachment container protocol.
public protocol AttachmentRepresentable {
    /// An attachment. See `ActivityAttachment`.
    var attachment: ActivityAttachment? { get }
}

extension AttachmentRepresentable {
    /// Returns the Open Graph data. See `OGResponse`.
    public var ogData: OGResponse? {
        return attachment?.openGraphData
    }
    
    /// Returns a list of image URl's froim the attachment. See `ActivityAttachment`.
    public func attachmentImageURLs() -> [URL]? {
        if let imageURLs = attachment?.imageURLs, imageURLs.count > 0 {
            return imageURLs
        }
        
        return nil
    }
}
