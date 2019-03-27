//
//  CommentTableViewCell.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 06/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

open class CommentTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var avatarLeadingConstraint: NSLayoutConstraint!
    @IBOutlet public weak var avatarImageView: UIImageView!
    @IBOutlet private weak var commentLabel: UILabel!
    @IBOutlet public weak var replyButton: UIButton!
    @IBOutlet public weak var likeButton: LikeButton!
    @IBOutlet weak var moreRepliesStackView: UIStackView!
    @IBOutlet weak var moreRepliesLabel: UILabel!
    
    public var withIndent: Bool {
        get { return avatarLeadingConstraint.constant != 0 }
        set {
            avatarLeadingConstraint.constant = newValue ? avatarImageView.bounds.width + 8 : 0
            
            if newValue {
                replyButton.isHidden = true
                likeButton.isHidden = true
            }
        }
    }
    
    public var moreReplies: String {
        get { return moreRepliesLabel.text ?? "" }
        set {
            moreRepliesStackView.isHidden = newValue.isEmpty
            moreRepliesLabel.text = newValue
        }
    }
    
    open override func reset() {
        avatarImageView.image = .userIcon
        commentLabel.attributedText = nil
        replyButton.removeTap()
        replyButton.isSelected = false
        replyButton.isHidden = false
        likeButton.removeTap()
        likeButton.isSelected = false
        likeButton.isHidden = false
        withIndent = false
        moreReplies = ""
    }
    
    public func updateComment(name: String, comment: String, date: Date) {
        let attributedText = NSMutableAttributedString(string: name, attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .bold)])
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
