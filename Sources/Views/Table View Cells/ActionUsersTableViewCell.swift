//
//  ActionUsersTableViewCell.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 01/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

class ActionUsersTableViewCell: BaseTableViewCell {

    @IBOutlet weak var avatarsStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    
    open override func reset() {
        avatarsStackView.cancelImagesLoading()
        titleLabel.text = nil
    }
}
