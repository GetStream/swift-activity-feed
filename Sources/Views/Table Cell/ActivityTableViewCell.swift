//
//  ActivityTableViewCell.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 18/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import Reusable
import GetStream

open class ActivityTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet public weak var avatarButton: UIButton!
    @IBOutlet public weak var nameLabel: UILabel!
    @IBOutlet private weak var repostInfoStackView: UIStackView!
    @IBOutlet private weak var repostInfoLabel: UILabel!
    @IBOutlet public weak var dateLabel: UILabel!
    @IBOutlet public weak var messageLabel: UILabel!
    @IBOutlet public weak var actionButtonsStackView: UIStackView!
    @IBOutlet public weak var replyButton: UIButton!
    @IBOutlet public weak var repostButton: UIButton!
    @IBOutlet public weak var likeButton: UIButton!
    
    public var repost: String? {
        get {
            return repostInfoLabel.text
        }
        set {
            if let reply = newValue {
                repostInfoStackView.isHidden = false
                repostInfoLabel.text = reply
            } else {
                repostInfoStackView.isHidden = true
            }
        }
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }
    
    open override func prepareForReuse() {
        reset()
        super.prepareForReuse()
    }
    
    open func reset() {
        updateAvatar(with: nil)
        nameLabel.text = nil
        repostInfoStackView.isHidden = true
        repostInfoLabel.text = nil
        dateLabel.text = nil
        messageLabel.text = nil
        actionButtonsStackView.isHidden = true
        replyButton.setTitle(nil, for: .normal)
        repostButton.setTitle(nil, for: .normal)
        likeButton.setTitle(nil, for: .normal)
        likeButton.isSelected = false
        avatarButton.removeTap()
        replyButton.removeTap()
        repostButton.removeTap()
        likeButton.removeTap()
        avatarButton.isEnabled = true
        replyButton.isEnabled = true
        repostButton.isEnabled = true
        likeButton.isEnabled = true
    }
    
    func updateAvatar(with image: UIImage?) {
        if let image = image {
            avatarButton.setImage(image, for: .normal)
            avatarButton.contentHorizontalAlignment = .fill
            avatarButton.contentVerticalAlignment = .fill
        } else {
            avatarButton.setImage(.profileIcon, for: .normal)
            avatarButton.contentHorizontalAlignment = .center
            avatarButton.contentVerticalAlignment = .center
        }
    }
}
