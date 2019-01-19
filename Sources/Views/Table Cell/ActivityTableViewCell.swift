//
//  ActivityTableViewCell.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 18/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import Reusable

open class ActivityTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet private weak var replyInfoStackView: UIStackView!
    @IBOutlet private weak var replyInfoLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var actionButtonsStackView: UIStackView!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var reshareButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    public var reply: String? {
        get {
            return replyInfoLabel.text
        }
        set {
            if let reply = newValue {
                replyInfoStackView.isHidden = false
                replyInfoLabel.text = reply
            } else {
                replyInfoStackView.isHidden = true
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
        avatarImageView.image = UIImage(named: "user_icon")
        nameLabel.text = nil
        replyInfoStackView.isHidden = true
        replyInfoLabel.text = nil
        dateLabel.text = nil
        messageLabel.text = nil
        actionButtonsStackView.isHidden = true
        reshareButton.setTitle(nil, for: .normal)
        likeButton.setTitle(nil, for: .normal)
        replyButton.removeTap()
        reshareButton.removeTap()
        likeButton.removeTap()
    }
}
