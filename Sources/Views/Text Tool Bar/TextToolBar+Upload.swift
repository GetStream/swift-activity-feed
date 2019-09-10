//
//  TextToolBar+Upload.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 25/03/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import GetStream

extension TextToolBar {
    
    /// Upload images and get URL's.
    public func uploadImages(imagePrefixFileName: String = "image",
                             _ completion: @escaping (_ imageURLs: [URL]?, _ error: Error?) -> Void) {
        File.files(from: images, process: { File(name: imagePrefixFileName.appending(String($0)), jpegImage: $1) }) { files in
            Client.shared.upload(images: files) { result in
                do {
                    
                let imageURLs = try result.get()
                    completion(imageURLs, nil)
                } catch {
                    completion(nil, error)
                }
            }
        }
    }
}
