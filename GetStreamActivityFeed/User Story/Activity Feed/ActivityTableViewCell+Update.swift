//
//  ActivityTableViewCell+Update.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 21/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import Nuke

extension ActivityTableViewCell {
    private static let imageLoaderOptions = ImageLoadingOptions(placeholder: .profileIcon,
                                                                failureImage: .profileIcon,
                                                                contentModes: .init(success: .scaleAspectFill,
                                                                                    failure: .center,
                                                                                    placeholder: .center))
    
    func update(with activity: Activity) {
        nameLabel.text = activity.actor.name
        messageLabel.text = activity.text
        var repostActivity: Activity?
        
        switch activity.object {
        case .text(let text):
            messageLabel.text = text
        case .image:
            break
        case .repost(let activity):
            repostActivity = activity
            
            switch activity.object {
            case .text(let string):
                messageLabel.text = string
            default:
                break
            }
        }
        
        dateLabel.text = activity.time?.relative
        actionButtonsStackView.isHidden = false
        
        if activity.verb == .repost {
            repost = "repost of \(repostActivity?.actor.name ?? "")"
        }
    }
    
    func updateAvatar(with activity: Activity, action: UIControl.Action? = nil) {
        if let action = action {
            avatarButton.addTap(action)
        }
        
        if let avatarURL = activity.actor.avatarURL {
            ImagePipeline.shared.loadImage(with: avatarURL.imageRequest(in: avatarButton)) { [weak self] response, error in
                self?.updateAvatar(with: response?.image)
            }
        }
    }
    
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
