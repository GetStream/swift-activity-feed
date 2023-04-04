//
//  UIStackView+LoadingImages.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 06/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import Nuke

extension UIStackView {
    private struct AssociatedKeys {
        static var imageTasksKey: UInt8 = 0
    }
    
    private var imageTasks: [ImageTask] {
        get { return (objc_getAssociatedObject(self, &AssociatedKeys.imageTasksKey) as? [ImageTask]) ?? [] }
        set { objc_setAssociatedObject(self, &AssociatedKeys.imageTasksKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// Load images with given URL's to UIImageView's in the stack view.
    /// The URL index from the array will match the UIImageView from the stack view.
    public func loadImages(with imageURLs: [URL]) {
        guard imageURLs.count > 0 else {
            return
        }
        
        var imageURLs = imageURLs
        
        if imageURLs.count > arrangedSubviews.count {
            imageURLs = Array(imageURLs.dropLast(imageURLs.count - arrangedSubviews.count))
        }
        
        imageURLs.enumerated().forEach { index, url in
            let task = ImagePipeline.shared.loadImage(with: url, completion:  { [weak self] result in
                if let response = try? result.get() {
                    self?.addImage(at: index, response.image)
                }
            })
            
            imageTasks.append(task)
        }
    }
    
    /// Cancel image loading tasks and set the `nil` to each image in `UIImageView` from the stack view.
    /// The `isHidden` property of `UIImageView` will be false.
    public func cancelImagesLoading() {
        arrangedSubviews.forEach {
            if let imageView = $0 as? UIImageView {
                imageView.image = nil
                imageView.isHidden = false
            }
        }
        
        imageTasks.forEach { $0.cancel() }
        imageTasks = []
    }
    
    private func addImage(at index: Int, _ image: UIImage?) {
        guard let imageView = arrangedSubviews[index] as? UIImageView else {
            return
        }
        
        imageView.image = image
        imageView.isHidden = image == nil
    }
}
