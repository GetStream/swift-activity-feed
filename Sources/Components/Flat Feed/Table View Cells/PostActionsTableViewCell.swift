//
//  PostActionsTableViewCell.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 31/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import Reusable

open class PostActionsTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet public weak var replyButton: UIButton!
    @IBOutlet public weak var repostButton: RepostButton!
    @IBOutlet public weak var likeButton: LikeButton!
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }
    
    open override func prepareForReuse() {
        reset()
        super.prepareForReuse()
    }
    
    open func reset() {
        replyButton.setTitle(nil, for: .normal)
        repostButton.setTitle(nil, for: .normal)
        likeButton.setTitle(nil, for: .normal)
        replyButton.isSelected = false
        likeButton.isSelected = false
        repostButton.isSelected = false
        replyButton.removeTap()
        repostButton.removeTap()
        likeButton.removeTap()
        replyButton.isEnabled = true
        repostButton.isEnabled = true
        likeButton.isEnabled = true
    }
}

// MARK: - Update with Activity

extension PostActionsTableViewCell {
    
    func updateReply(with activity: Activity, action: UIControl.Action? = nil) {
        if let action = action {
            replyButton.addTap(action)
        }
        
        replyButton.setTitle(String(activity.originalActivity.commentsCount), for: .normal)
    }
    
    func updateRepost(with activity: Activity, action: UIControl.Action? = nil) {
        if let action = action {
            repostButton.addTap(action)
        }
        
        repostButton.setTitle(String(activity.originalActivity.repostsCount), for: .normal)
        repostButton.isSelected = activity.originalActivity.isReposted
    }
    
    func updateLike(with activity: Activity, action: UIControl.Action? = nil) {
        if let action = action {
            likeButton.addTap(action)
        }
        
        likeButton.setTitle(String(activity.originalActivity.likesCount), for: .normal)
        likeButton.isSelected = activity.originalActivity.isLiked
    }
}
