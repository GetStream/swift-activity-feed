//
//  PostAttachmentImagesTableViewCell.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 31/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

class PostAttachmentImagesTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var stackView: UIStackView!
    
    open override func reset() {
        stackView.cancelImagesLoading()
    }
}
