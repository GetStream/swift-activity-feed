//
//  PostAttachmentImagesTableViewCell.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 31/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import Reusable
import Nuke

class PostAttachmentImagesTableViewCell: UITableViewCell, NibReusable {
    
    @IBOutlet weak var stackView: UIStackView!
    private var imageTasks: [ImageTask] = []
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }
    
    open override func prepareForReuse() {
        reset()
        super.prepareForReuse()
    }
    
    open func reset() {
        stackView.arrangedSubviews.forEach {
            if let imageView = $0 as? UIImageView {
                imageView.image = nil
            }
        }
        
        imageTasks.forEach { $0.cancel() }
        imageTasks = []
    }
    
    public func update(with imageURLs: [URL]) {
        var imageURLs = imageURLs
        
        if imageURLs.count > stackView.arrangedSubviews.count {
            imageURLs = Array(imageURLs.dropLast(imageURLs.count - stackView.arrangedSubviews.count))
        }
        
        imageURLs.enumerated().forEach { index, url in
            let task = ImagePipeline.shared.loadImage(with: url) { [weak self] response, error in
                self?.addImage(at: index, response?.image)
            }
            
            imageTasks.append(task)
        }
    }
    
    private func addImage(at index: Int, _ image: UIImage?) {
        guard let imageView = stackView.arrangedSubviews[index] as? UIImageView else {
            return
        }
        
        imageView.image = image
    }
}
