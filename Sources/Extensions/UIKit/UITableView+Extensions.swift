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
    public func postCell<T: ActivityProtocol>(at indexPath: IndexPath,
                                              presenter: ActivityPresenter<T>) -> UITableViewCell?
        where T.ActorType: UserNameRepresentable, T.ReactionType: ReactionProtocol {
            let cellsCount = presenter.cellsCount
            let originalActivity = presenter.originalActivity
            let attachmentActivity = originalActivity as? AttachmentRepresentable
            
            switch indexPath.row {
            case 0:
                // Header with Text and/or Image.
                let cell = dequeueReusableCell(for: indexPath) as PostHeaderTableViewCell
                cell.update(with: presenter.activity, originalActivity: originalActivity)
                return cell
                
            case (cellsCount - 4):
                // Images.
                if let cell = postAttachmentImagesTableViewCell(attachmentActivity, at: indexPath) {
                    return cell
                }
                
            case (cellsCount - 3): // Open Graph Data or Images.
                if let ogData = attachmentActivity?.ogData {
                    let cell = dequeueReusableCell(for: indexPath) as OpenGraphTableViewCell
                    cell.update(with: ogData)
                    return cell
                    
                } else if let cell = postAttachmentImagesTableViewCell(attachmentActivity, at: indexPath) {
                    return cell
                }
                
            case (cellsCount - 2): // Activities.
                return dequeueReusableCell(for: indexPath) as PostActionsTableViewCell
                
            case (cellsCount - 1): // Separator.
                return dequeueReusableCell(for: indexPath) as SeparatorTableViewCell
            default:
                break
            }
            
            return nil
    }
    
    private func postAttachmentImagesTableViewCell(_ attachmentRepresentable: AttachmentRepresentable?,
                                                   at indexPath: IndexPath) -> UITableViewCell? {
        guard let attachmentRepresentable = attachmentRepresentable,
            let imageURLs = attachmentRepresentable.attachmentImageURLs() else {
                return nil
        }
        
        let cell = dequeueReusableCell(for: indexPath) as PostAttachmentImagesTableViewCell
        cell.stackView.loadImages(with: imageURLs)
        return cell
    }
}
