//
//  OpenGraphTableViewCell+Update.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 28/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import GetStream

extension OpenGraphTableViewCell {
    public func update(with ogData: OGResponse) {
        titleLabel.text = ogData.title
        descriptionLabel.text = ogData.description
        
        if let imageURLString = ogData.images?.first?.image {
            var imageURLString = imageURLString
            
            if imageURLString.hasPrefix("//") {
                imageURLString = "https:\(imageURLString)"
            }
            
            updatePreviewImage(with: URL(string: imageURLString))
        }
    }
}
