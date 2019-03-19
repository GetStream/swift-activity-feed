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
    public func postCell<T: ActivityProtocol>(at indexPath: IndexPath, presenter: ActivityPresenter<T>) -> UITableViewCell?
        where T.ActorType: UserNameRepresentable, T.ReactionType: ReactionProtocol {
            guard let cellType = presenter.cellType(at: indexPath) else {
                return nil
            }
            
            switch cellType {
            case .activity:
                let cell = dequeueReusableCell(for: indexPath) as PostHeaderTableViewCell
                cell.update(with: presenter.activity, originalActivity: presenter.originalActivity)
                return cell
            case .attachmentImages(let urls):
                let cell = dequeueReusableCell(for: indexPath) as PostAttachmentImagesTableViewCell
                cell.stackView.loadImages(with: urls)
                return cell
            case .attachmentOpenGraphData(let ogData):
                let cell = dequeueReusableCell(for: indexPath) as OpenGraphTableViewCell
                cell.update(with: ogData)
                return cell
            case .actions:
                return dequeueReusableCell(for: indexPath) as PostActionsTableViewCell
            case .separator:
                return dequeueReusableCell(for: indexPath) as SeparatorTableViewCell
            }
    }
}
