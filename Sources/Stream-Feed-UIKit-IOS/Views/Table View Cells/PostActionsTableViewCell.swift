//
//  PostActionsTableViewCell.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 31/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import Reusable
import GetStream

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
        replyButton.isHidden = true
        repostButton.isHidden = true
        likeButton.isHidden = true
    }
}

// MARK: - Update with Activity

extension PostActionsTableViewCell {
    
    public func updateReply(commentsCount: Int, action: UIControl.Action? = nil) {
        if let action = action {
            replyButton.addTap(action)
        }
        
        if commentsCount > 0 {
            replyButton.setTitle(String(commentsCount), for: .normal)
        }
        
        replyButton.isHidden = false
    }
    
    public func updateRepost(isReposted: Bool, repostsCount: Int, action: UIControl.Action? = nil) {
        if let action = action {
            repostButton.addTap(action)
        }
        
        if repostsCount > 0 {
            repostButton.setTitle(String(repostsCount), for: .normal)
        }
        
        repostButton.isSelected = isReposted
        repostButton.isHidden = false
    }
    
    public func updateLike(isLiked: Bool, likesCount: Int, action: UIControl.Action? = nil) {
        if let action = action {
            likeButton.addTap(action)
        }
        
        if likesCount > 0 {
            likeButton.setTitle(String(likesCount), for: .normal)
        }
        
        likeButton.isSelected = isLiked
        likeButton.isHidden = false
    }
}

// MARK: - Update For ActivityPresenter

extension PostActionsTableViewCell {
    
    public func updateRepost<T: ActivityProtocol, U: UserProtocol>(presenter: ActivityPresenter<T>,
                                                                   targetFeedId feedId: FeedId,
                                                                   userTypeOf userType: U.Type,
                                                                   _ completion: @escaping ReactionButton.ErrorCompletion)
        where T.ReactionType == GetStream.Reaction<ReactionExtraData, U> {
            updateRepost(isReposted: presenter.originalActivity.isUserReposted,
                         repostsCount: presenter.originalActivity.repostsCount) {
                            if let button = $0 as? RepostButton {
                                button.repost(presenter.originalActivity,
                                              presenter: presenter.reactionPresenter,
                                              userTypeOf: userType,
                                              targetsFeedIds: [feedId],
                                              completion)
                            }
            }
    }
    
    public func updateLike<T: ActivityProtocol, U: UserProtocol>(presenter: ActivityPresenter<T>,
                                                                 userTypeOf userType: U.Type,
                                                                 _ completion: @escaping ReactionButton.ErrorCompletion)
        where T.ReactionType == GetStream.Reaction<ReactionExtraData, U> {
            updateLike(isLiked: presenter.originalActivity.isUserLiked,
                       likesCount: presenter.originalActivity.likesCount) {
                        if let button = $0 as? LikeButton {
                            button.like(presenter.originalActivity,
                                        presenter: presenter.reactionPresenter,
                                        userTypeOf: userType,
                                        completion)
                        }
            }
    }
}
