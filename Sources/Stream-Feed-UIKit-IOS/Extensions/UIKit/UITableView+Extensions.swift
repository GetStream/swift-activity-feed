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
    /// The registration of all table view cells from Activity Feed Components.
    public func registerCells() {
        register(UINib(nibName: "PostHeaderTableViewCell", bundle: .module), forCellReuseIdentifier: "PostHeaderTableViewCell")
        register(UINib(nibName: "PostActionsTableViewCell", bundle: .module), forCellReuseIdentifier: "PostActionsTableViewCell")
        register(UINib(nibName: "PostAttachmentImagesTableViewCell", bundle: .module), forCellReuseIdentifier: "PostAttachmentImagesTableViewCell")
        register(UINib(nibName: "OpenGraphTableViewCell", bundle: .module), forCellReuseIdentifier: "OpenGraphTableViewCell")
        register(UINib(nibName: "SeparatorTableViewCell", bundle: .module), forCellReuseIdentifier: "SeparatorTableViewCell")
       register(UINib(nibName: "ActionUsersTableViewCell", bundle: .module), forCellReuseIdentifier: "ActionUsersTableViewCell")
        register(UINib(nibName: "CommentTableViewCell", bundle: .module), forCellReuseIdentifier: "CommentTableViewCell")
       register(UINib(nibName: "PaginationTableViewCell", bundle: .module), forCellReuseIdentifier: "PaginationTableViewCell")
    }
}

// MARK: - Cells

extension UITableView {
    /// Dequeue reusable activity feed post cells with a given indexPath and activity presenter.
    ///
    /// - Parameters:
    ///     - indexPath: the index path of the requested cell.
    ///     - presenter: the `ActivityPresenter` for the requested cell.
    public func postCell<T: ActivityProtocol>(at indexPath: IndexPath, presenter: ActivityPresenter<T>, imagesTappedAction: (([URL]) -> ())? = nil, sendImageURLValues: (([URL]) -> ())? = nil) -> UITableViewCell?
        where T.ActorType: UserNameRepresentable, T.ReactionType: ReactionProtocol {
            guard let cellType = presenter.cellType(at: indexPath.row) else {
                return nil
            }
            
            switch cellType {
            case .activity:
                let cell = dequeueReusableCell(for: indexPath) as PostHeaderTableViewCell
                cell.update(with: presenter.activity, originalActivity: presenter.originalActivity)
                return cell
            case .attachmentImages(let urls):
                let cell = dequeueReusableCell(for: indexPath) as PostAttachmentImagesTableViewCell
                cell.stackView.arrangedSubviews.forEach { $0.isHidden = true }
                cell.scrollView.isUserInteractionEnabled = (imagesTappedAction != nil)
                cell.stackView.loadImages(with: urls)
                sendImageURLValues?(urls)
                cell.imagesTapped = {
                    imagesTappedAction?(urls)
                }
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
