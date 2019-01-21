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
    
    open var presenter: FlatFeedPresenter<Activity>?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        tabBarItem = UITabBarItem(title: "Home", image: .homeIcon, tag: 0)
        setupTableView()
        setupRefreshControl()
        reloadData()
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
        
        cell.update(with: activity,
                    replyAction: { [weak self, weak activity] in
                        if let button = $0 as? UIButton, let activity = activity {
                            self?.reply(activity, button: button)
                        }
            },
                    repostAction: { [weak self, weak activity] in
                        if let button = $0 as? UIButton, let activity = activity {
                            self?.repost(activity, button: button)
                        }
            },
                    likeAction: { [weak self, weak activity] in
                        if let button = $0 as? UIButton, let activity = activity {
                            self?.like(activity, button: button)
                        }
        })
        
        return cell
    }
    
    open override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    open override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}

extension FlatFeedViewController {
    func reply(_ activity: Activity, button: UIButton) {
    }
    
    func repost(_ activity: Activity, button: UIButton) {
    }
}

// MARK: - LIKE

extension FlatFeedViewController {
    func like(_ activity: Activity, button: UIButton) {
        if button.isSelected {
            if let likedReaction = activity.likedReaction {
                button.isEnabled = false
                
                presenter?.dislike(activity, likedReaction) { [weak self, weak button] error in
                    if let error = error {
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
        refreshControl?.addAction(for: .valueChanged) { [weak self] _ in self?.reloadData() }
    }
}
