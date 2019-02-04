//
//  ActionUsersTableViewCell.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 01/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

class ActionUsersTableViewCell: BaseTableViewCell {

    @IBOutlet private weak var avatarsStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override open func reset() {
        avatarsStackView.arrangedSubviews.forEach { ($0 as? UIImageView)?.image = nil }
        titleLabel.text = nil
    }
}
