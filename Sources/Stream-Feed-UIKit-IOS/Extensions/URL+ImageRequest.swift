//
//  URL+ImageRequest.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 22/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import Nuke
import Foundation

extension URL {
    func imageRequest(in view: UIView) -> ImageRequest {
        let size = CGSize(width: view.bounds.width, height: view.bounds.width)
        let processors = [ImageProcessors.Resize(size: size, unit: .points, contentMode: .aspectFill, crop: true, upscale: false)]
        return ImageRequest(url: self, processors: processors)
    }
    
    func getImageID() -> String {
         let pathComponents = self.pathComponents
         guard pathComponents.count > 2 else { return "" }
         let imageId = pathComponents[3]
         
         return imageId
     }
}
