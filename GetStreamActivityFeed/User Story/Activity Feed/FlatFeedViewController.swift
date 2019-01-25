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
}

// MARK: - Table View

extension FlatFeedViewController {
    
    func setupTableView() {
        tableView.register(cellType: ActivityTableViewCell.self)
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
        return 1
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as ActivityTableViewCell
        
        guard let presenter = presenter,
            indexPath.row < presenter.activities.count else {
                return cell
        }
        
        let activity = presenter.activities[indexPath.section]
        let user = activity.actor
        
        cell.update(with: activity)
        
        cell.updateAvatar(with: activity) { [weak self] _ in
            if let profileViewCotroller = self?.profileBuilder?.profileViewController(user: user) {
                profileViewCotroller.builder = self?.profileBuilder
                self?.navigationController?.pushViewController(profileViewCotroller, animated: true)
            }
        }
        
        cell.updateReply(with: activity)
        
        cell.updateRepost(with: activity) { [weak self, weak activity] in
            if let self = self,
                let userFeedId = UIApplication.shared.appDelegate.userFeed?.feedId,
                let button = $0 as? RepostButton,
                let activity = activity,
                let presenter = self.presenter {
                button.react(with: presenter.reactionPresenter,
                             activity: activity,
                             targetsFeedIds: [userFeedId],
                             self.showErrorAlertIfNeeded)
            }
        }
        
        cell.updateLike(with: activity) { [weak self, weak activity] in
            if let self = self, let button = $0 as? LikeButton, let activity = activity, let presenter = self.presenter {
                button.react(with: presenter.reactionPresenter, activity: activity, self.showErrorAlertIfNeeded)
            }
        }
        
        return cell
    }
    
    open override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    open override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
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
        return removeActivityAction != nil
    }
}

// MARK: - Refresh Control

extension FlatFeedViewController {
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addValueChangedAction { [weak self] _ in self?.reloadData() }
    }
}
