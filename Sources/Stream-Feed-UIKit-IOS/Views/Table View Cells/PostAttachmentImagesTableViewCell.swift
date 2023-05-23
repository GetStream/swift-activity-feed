//
//  PostAttachmentImagesTableViewCell.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 31/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

class PostAttachmentImagesTableViewCell: BaseTableViewCell {
    
    @IBOutlet public weak var stackView: UIStackView!
    @IBOutlet public weak var scrollView: UIScrollView!
    
    var imagesTapped: (() -> Void)?
    
    open override func reset() {
        stackView.cancelImagesLoading()
        scrollView.semanticContentAttribute = .forceLeftToRight
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        scrollView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func imageTapped() {
        imagesTapped?()
    }
    
}
