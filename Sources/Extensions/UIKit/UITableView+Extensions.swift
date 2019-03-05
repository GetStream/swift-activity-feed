//
//  UITableView+Extensions.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 01/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import GetStream

// MARK: - Setup Post Table View

extension UITableView {
    public func registerPostCells() {
        register(cellType: PostHeaderTableViewCell.self)
        register(cellType: PostActionsTableViewCell.self)
        register(cellType: PostAttachmentImagesTableViewCell.self)
        register(cellType: OpenGraphTableViewCell.self)
        register(cellType: SeparatorTableViewCell.self)
        register(cellType: ActionUsersTableViewCell.self)
        register(cellType: CommentTableViewCell.self)
        register(cellType: PaginationTableViewCell.self)
    }
}

// MARK: - Cells

extension UITableView {
    public func postCell(at indexPath: IndexPath,
                         in viewController: UIViewController,
                         presenter: ActivityPresenter<Activity>,
                         feedId: FeedId?) -> UITableViewCell? {
        let cellsCount = presenter.cellsCount
        
        switch indexPath.row {
        case 0:
            // Header with Text and/or Image.
            let cell = dequeueReusableCell(for: indexPath) as PostHeaderTableViewCell
            cell.update(with: presenter.activity)
            return cell
            
        case (cellsCount - 4):
            // Images.
            if presenter.attachmentImageURLs() != nil {
                return postAttachmentImagesTableViewCell(presenter, at: indexPath)
            }
            
        case (cellsCount - 3): // Open Graph Data or Images.
            if let ogData = presenter.ogData {
                let cell = dequeueReusableCell(for: indexPath) as OpenGraphTableViewCell
                cell.update(with: ogData)
                return cell
                
            } else if presenter.attachmentImageURLs() != nil {
                // Images.
                return postAttachmentImagesTableViewCell(presenter, at: indexPath)
            }
        case (cellsCount - 2): // Activities.
            let cell = dequeueReusableCell(for: indexPath) as PostActionsTableViewCell
            
            // Reply.
            cell.updateReply(commentsCount: presenter.activity.original.commentsCount)
            
            // Repost.
            if let feedId = feedId {
                cell.updateRepost(isReposted: presenter.activity.original.isUserReposted,
                                  repostsCount: presenter.activity.original.repostsCount) { [weak viewController] in
                                    if let button = $0 as? RepostButton,
                                        let viewController = viewController {
                                        button.react(with: presenter.reactionPresenter,
                                                     activity: presenter.activity,
                                                     targetsFeedIds: [feedId],
                                                     viewController.showErrorAlertIfNeeded)
                                    }
                }
            }
            
            // Like.
            cell.updateLike(isLiked: presenter.activity.original.isUserLiked,
                            likesCount: presenter.activity.original.likesCount) { [weak viewController] in
                if let button = $0 as? LikeButton, let viewController = viewController {
                    button.react(with: presenter.reactionPresenter,
                                 activity: presenter.activity,
                                 viewController.showErrorAlertIfNeeded)
                }
            }
            
            return cell
            
        case (cellsCount - 1): // Separator.
            return dequeueReusableCell(for: indexPath) as SeparatorTableViewCell
        default:
            break
        }
        
        return nil
    }
    
    private func postAttachmentImagesTableViewCell(_ presenter: ActivityPresenter<Activity>,
                                                   at indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(for: indexPath) as PostAttachmentImagesTableViewCell
        
        if let imageURLs = presenter.attachmentImageURLs() {
            cell.stackView.loadImages(with: imageURLs)
        }
        
        return cell
    }
}
