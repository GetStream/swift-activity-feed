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
    
    func update(with activity: Activity,
                replyAction: UIControl.Action? = nil,
                repostAction: UIControl.Action? = nil,
                likeAction: UIControl.Action? = nil) {
        nameLabel.text = activity.actor.name
        messageLabel.text = activity.text ?? activity.object
        dateLabel.text = activity.time?.relative
        actionButtonsStackView.isHidden = false
        
        if let avatarURL = activity.actor.avatarURL {
            Nuke.loadImage(with: avatarURL, options: ActivityTableViewCell.imageLoaderOptions, into: avatarImageView)
        }
        
        if activity.verb == .reply {
            reply = "reply to \(activity.target ?? "")"
        }
        
        if let replyAction = replyAction {
            replyButton.addTap(replyAction)
        }
        
        if let repostAction = repostAction {
            repostButton.addTap(repostAction)
        }
        
        if let likeAction = likeAction {
            likeButton.addTap(likeAction)
        }
        
        likeButton.setTitle(String(activity.reactionCounts?[.like] ?? 0), for: .normal)
        likeButton.isSelected = activity.isLiked
    }
}
