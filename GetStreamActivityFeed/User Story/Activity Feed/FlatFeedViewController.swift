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
import Nuke

open class FlatFeedViewController: UITableViewController, BundledStoryboardLoadable {
    
    open var presenter: FlatFeedPresenter<Activity>?
    
    private let imageLoaderOptions = ImageLoadingOptions(placeholder: UIImage(named: "user_icon"),
                                                         failureImage: UIImage(named: "user_icon"),
                                                         contentModes: .init(success: .scaleAspectFill,
                                                                             failure: .center,
                                                                             placeholder: .center))
    
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
        cell.nameLabel.text = activity.actor.name
        cell.messageLabel.text = activity.text ?? activity.object
        cell.dateLabel.text = activity.time?.relative
        cell.actionButtonsStackView.isHidden = false
        
        if let avatarURL = activity.actor.avatarURL {
            Nuke.loadImage(with: avatarURL, options: imageLoaderOptions, into: cell.avatarImageView)
        }
        
        if activity.verb == "reply" {
            cell.reply = "reply to Leonhard konijn"
        }
        
        return cell
    }
    
    open override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    open override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}

// MARK: - Refresh Control

extension FlatFeedViewController {
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addAction(for: .valueChanged) { [weak self] _ in self?.reloadData() }
    }
}
