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

open class FlatFeedViewController: UITableViewController, BundledStoryboardLoadable {
    typealias RemoveActivityAction = (_ activity: Activity) -> Void
    
    static var storyboardName = "ActivityFeed"
    
    open var presenter: FlatFeedPresenter<Activity>?
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
        
        cell.updateReply(with: activity) { [weak self, weak activity] in
            if let button = $0 as? UIButton, let activity = activity?.originalActivity {
                self?.reply(activity, button: button)
            }
        }
        
        var repostAction: UIControl.Action?
        
        if let currentUser = UIApplication.shared.appDelegate.currentUser, currentUser != activity.actor {
            repostAction = { [weak self, weak activity] in
                if let button = $0 as? UIButton, let activity = activity?.originalActivity {
                    self?.repost(activity, button: button)
                }
            }
        }
        
        cell.updateRepost(with: activity, action: repostAction)
        
        cell.updateLike(with: activity) { [weak self, weak activity] in
            if let button = $0 as? UIButton, let activity = activity?.originalActivity {
                self?.like(activity, button: button)
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

extension FlatFeedViewController {
    func reply(_ activity: Activity, button: UIButton) {
        
    }
    
    func repost(_ activity: Activity, button: UIButton) {
        guard !button.isSelected else {
            return
        }
        
        button.isEnabled = false
        
        presenter?.repost(activity, completion: { [weak self, weak button] error in
            button?.isEnabled = true
            
            if let error = error {
                print("❌", error)
                self?.showErrorAlert(error)
            } else {
                button?.setTitle(String(activity.repostsCount), for: .normal)
                button?.isSelected = true
            }
        })
    }
}

// MARK: - LIKE

extension FlatFeedViewController {
    func like(_ activity: Activity, button: UIButton) {
        if button.isSelected {
            if let likedReaction = activity.likedReaction {
                button.isEnabled = false
                
                presenter?.remove(reaction: likedReaction, for: activity) { [weak self, weak button] error in
                    button?.isEnabled = true
                    
                    if let error = error {
                        print("❌", error)
                        self?.showErrorAlert(error)
                    } else {
                        button?.isSelected = false
                        self?.updateLikeCounter(for: activity, button)
                    }
                }
            } else {
                button.isSelected = false
            }
            
            return
        }
        
        button.isEnabled = false
        
        presenter?.like(activity) { [weak self, weak button] error in
            button?.isEnabled = true
            
            if let error = error {
                self?.showErrorAlert(error)
            } else {
                button?.isSelected = true
                self?.updateLikeCounter(for: activity, button)
            }
        }
    }
    
    private func updateLikeCounter(for activity: Activity, _ button: UIButton?) {
        button?.isEnabled = true
        button?.setTitle(String(activity.reactionCounts?[.like] ?? 0), for: .normal)
    }
}

// MARK: - Refresh Control

extension FlatFeedViewController {
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addValueChangedAction { [weak self] _ in self?.reloadData() }
    }
}
