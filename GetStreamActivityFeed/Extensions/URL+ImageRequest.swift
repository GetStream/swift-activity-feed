//
//  URL+ImageRequest.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 22/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import Nuke

extension URL {
    func imageRequest(in view: UIView) -> ImageRequest {
        let imageSize = view.bounds.width * UIScreen.main.scale
        return ImageRequest(url: self, targetSize: CGSize(width: imageSize, height: imageSize), contentMode: .aspectFill)
    }
}
