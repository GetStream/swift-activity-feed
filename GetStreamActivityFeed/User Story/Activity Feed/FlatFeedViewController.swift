//
//  FeedViewController.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 17/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import GetStream
import Reusable
import Result

open class FlatFeedViewController: UITableViewController, BundledStoryboardLoadable {
    typealias RemoveActivityAction = (_ activity: Activity) -> Void
    
    static var storyboardName = "ActivityFeed"
    
    var presenter: FlatFeedPresenter<Activity>?
    var profileBuilder: ProfileBuilder?
    var removeActivityAction: RemoveActivityAction?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        tabBarItem = UITabBarItem(title: "Home", image: .homeIcon, tag: 0)
        hideBackButtonTitle()
        setupTableView()
        setupRefreshControl()
        reloadData()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if parent == nil || parent is UINavigationController {
            navigationController?.restoreDefaultNavigationBar(animated: animated)
            reloadData()
        }
    }
    
    private func activity(in section: Int) -> Activity? {
        guard let presenter = presenter, section < presenter.activities.count else {
            return nil
        }
        
        return presenter.activities[section]
    }
    
    private func ogData(in section: Int) -> OGResponse? {
        if let activity = activity(in: section), let attachment = activity.originalActivity.attachment {
            return attachment.openGraphData
        }
        
        return nil
    }
    
    private func attachmentImageURLs(in section: Int) -> [URL]? {
        if let imageURLs = activity(in: section)?.attachment?.imageURLs, imageURLs.count > 0 {
            return imageURLs
        }
        
        return nil
    }
    
    private func cellsCount(in section: Int) -> Int {
        guard activity(in: section) != nil else {
            return 0
        }
        
        var count = 3
        
        if attachmentImageURLs(in: section) != nil {
            count += 1
        }
        
        if ogData(in: section) != nil {
            count += 1
        }
        
        return count
    }
}

// MARK: - Table View

extension FlatFeedViewController {
    
    func setupTableView() {
        tableView.register(cellType: PostHeaderTableViewCell.self)
        tableView.register(cellType: PostActionsTableViewCell.self)
        tableView.register(cellType: PostAttachmentImagesTableViewCell.self)
        tableView.register(cellType: OpenGraphTableViewCell.self)
        tableView.register(cellType: SeparatorTableViewCell.self)
    }
    
    func reloadData() {
        presenter?.loadActivities { [weak self] error in
            self?.refreshControl?.endRefreshing()
            
            if let error = error {
                self?.showErrorAlert(error)
            } else {
                self?.tableView.reloadData()
            }
        }
    }
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return presenter?.activities.count ?? 0
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellsCount(in: section)
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let activity = activity(in: indexPath.section), let presenter = presenter else {
            return UITableViewCell(style: .default, reuseIdentifier: "unused")
        }
        
        let cellsCount = self.cellsCount(in: indexPath.section)
        
        switch indexPath.row {
        case 0:
            // Post Header and Text.
            let cell = tableView.dequeueReusableCell(for: indexPath) as PostHeaderTableViewCell
            let user = activity.actor
            cell.update(with: activity)
            
            cell.updateAvatar(with: activity) { [weak self] _ in
                if let profileViewCotroller = self?.profileBuilder?.profileViewController(user: user) {
                    profileViewCotroller.builder = self?.profileBuilder
                    self?.navigationController?.pushViewController(profileViewCotroller, animated: true)
                }
            }
            
            return cell
            
        case (cellsCount - 4):
            if attachmentImageURLs(in: indexPath.section) != nil {
                return postAttachmentImagesTableViewCell(activity, at: indexPath)
            }
            
        case (cellsCount - 3): // Open Graph Data.
            if let ogData = ogData(in: indexPath.section) {
                let cell = tableView.dequeueReusableCell(for: indexPath) as OpenGraphTableViewCell
                cell.update(with: ogData)
                return cell
                
            } else if attachmentImageURLs(in: indexPath.section) != nil {
                return postAttachmentImagesTableViewCell(activity, at: indexPath)
            }
        case (cellsCount - 2): // Post activities.
            let cell = tableView.dequeueReusableCell(for: indexPath) as PostActionsTableViewCell
            
            cell.updateReply(with: activity)
            
            cell.updateRepost(with: activity) { [weak self, weak activity, weak presenter] in
                if let self = self,
                    let userFeedId = UIApplication.shared.appDelegate.userFeed?.feedId,
                    let button = $0 as? RepostButton,
                    let activity = activity,
                    let presenter = presenter {
                    button.react(with: presenter.reactionPresenter,
                                 activity: activity,
                                 targetsFeedIds: [userFeedId],
                                 self.showErrorAlertIfNeeded)
                }
            }
            
            cell.updateLike(with: activity) { [weak self, weak activity] in
                if let self = self, let button = $0 as? LikeButton, let activity = activity {
                    button.react(with: presenter.reactionPresenter, activity: activity, self.showErrorAlertIfNeeded)
                }
            }
            
            return cell
            
        case (cellsCount - 1): // Separator.
            return tableView.dequeueReusableCell(for: indexPath) as SeparatorTableViewCell
        default:
            break
        }
        
        return UITableViewCell(style: .default, reuseIdentifier: "unused")
    }
    
    private func postAttachmentImagesTableViewCell(_ activity: Activity, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as PostAttachmentImagesTableViewCell
        
        if let imageURLs = activity.attachment?.imageURLs {
            cell.update(with: imageURLs)
        }
        
        return cell
    }
    
    open override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard indexPath.row == cellsCount(in: indexPath.section) - 3,
            let openGraph = ogData(in: indexPath.section) else {
            return false
        }
        
        return openGraph.url != nil
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let openGraph = self.ogData(in: indexPath.section)
        let viewController = WebViewController()
        viewController.url = openGraph?.url
        viewController.title = openGraph?.title
        present(UINavigationController(rootViewController: viewController), animated: true)
    }
    
    open override func tableView(_ tableView: UITableView,
                                 commit editingStyle: UITableViewCell.EditingStyle,
                                 forRowAt indexPath: IndexPath) {
        guard let presenter = presenter, indexPath.row < presenter.activities.count else {
            return
        }
        
        if editingStyle == .delete, let removeActivityAction = removeActivityAction {
            removeActivityAction(presenter.activities[indexPath.section])
        }
    }
    
    open override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return removeActivityAction != nil && indexPath.row == 0
    }
}

// MARK: - Refresh Control

extension FlatFeedViewController {
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addValueChangedAction { [weak self] _ in self?.reloadData() }
    }
}
