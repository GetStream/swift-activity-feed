//
//  UITableView+Extensions.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 01/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

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

public enum PostCellType {
    case feed
    case detail
}

extension UITableView {
    public func postCell(at indexPath: IndexPath,
                         in viewController: UIViewController,
                         type: PostCellType = .feed,
                         presenter: ActivityPresenter<Activity>) -> UITableViewCell? {
        let cellsCount = presenter.cellsCount
        var skipImageObject = false
        
        if type == .detail {
            skipImageObject = presenter.attachmentImageURLs != nil
        }
        
        switch indexPath.row {
        case 0:
            // Header with Text and/or Image.
            let cell = dequeueReusableCell(for: indexPath) as PostHeaderTableViewCell
            cell.update(with: presenter.activity, skipImageObject: skipImageObject)
            return cell
            
        case (cellsCount - 4):
            // Images.
            if presenter.attachmentImageURLs != nil {
                return postAttachmentImagesTableViewCell(presenter, at: indexPath, type: type)
            }
            
        case (cellsCount - 3): // Open Graph Data or Images.
            if let ogData = presenter.ogData {
                let cell = dequeueReusableCell(for: indexPath) as OpenGraphTableViewCell
                cell.update(with: ogData)
                return cell
                
            } else if presenter.attachmentImageURLs != nil {
                // Images.
                return postAttachmentImagesTableViewCell(presenter, at: indexPath, type: type)
            }
        case (cellsCount - 2): // Activities.
            let cell = dequeueReusableCell(for: indexPath) as PostActionsTableViewCell
            
            // Reply.
            cell.updateReply(with: presenter.activity)
            
            // Repost.
            cell.updateRepost(with: presenter.activity) { [weak viewController] in
                if let userFeedId = UIApplication.shared.appDelegate.userFeed?.feedId,
                    let button = $0 as? RepostButton,
                    let viewController = viewController {
                    button.react(with: presenter.reactionPresenter,
                                 activity: presenter.activity,
                                 targetsFeedIds: [userFeedId],
                                 viewController.showErrorAlertIfNeeded)
                }
            }
            
            // Like.
            cell.updateLike(with: presenter.activity) { [weak viewController] in
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
                                                   at indexPath: IndexPath,
                                                   type: PostCellType) -> UITableViewCell {
        let cell = dequeueReusableCell(for: indexPath) as PostAttachmentImagesTableViewCell
        
        if let imageURLs = presenter.attachmentImageURLs() {
            var imageURLs = imageURLs
            
            if type == .detail, case .image(let url) = presenter.activity.object {
                imageURLs.insert(url, at: 0)
            }
            
            cell.stackView.loadImages(with: imageURLs)
        }
        
        return cell
    }
}
