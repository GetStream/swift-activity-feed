//
//  CommentTableViewCell.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 06/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

open class CommentTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet private weak var commentLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var likeButton: LikeButton!
    
    open override func reset() {
        avatarImageView.image = .userIcon
        commentLabel.attributedText = nil
        replyButton.removeTap()
        likeButton.removeTap()
        replyButton.isSelected = false
        likeButton.isSelected = false
    }
    
    public func updateComment(name: String, comment: String, date: Date) {
        let attributedText = NSMutableAttributedString(string: name,
                                                       attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .bold)])
        
        let comment = NSAttributedString(string: "\n\(comment)", attributes: [.font: UIFont.systemFont(ofSize: 12)])
        attributedText.append(comment)
        let date = NSAttributedString(string: "\n\(date.relative)", attributes: [.foregroundColor: UIColor.lightGray])
        attributedText.append(date)
        
        attributedText.applyParagraphStyle { paragraphStyle in
            paragraphStyle.lineHeightMultiple = 1.2
        }
        
        commentLabel.attributedText = attributedText
    }
}
