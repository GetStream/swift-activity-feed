//
//  NotificationsViewController.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 14/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import GetStream

final class NotificationsViewController: UITableViewController, BundledStoryboardLoadable {
    
    static var storyboardName = "Notifications"
    
    var subscriptionId: SubscriptionId?
    
    var presenter: NotificationsPresenter<Activity>? {
        didSet {
            if let presenter = presenter {
                load()
                subscriptionId = presenter.subscribeForUpdates { [weak self] _ in self?.load() }
            }
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideBackButtonTitle()
        setupTableView()
        load()
    }
    
    private func setup() {
        tabBarItem = UITabBarItem(title: "Notifications", image: .bellIcon, tag: 1)
    }
    
    private func load() {
        if isViewLoaded {
            presenter?.markOption = .seenAll
        }
        
        presenter?.load { [weak self] in
            guard let self = self, let notificationsPresenter = self.presenter else {
                return
            }
            
            if let error = $0 {
                self.showErrorAlert(error)
            } else {
                if notificationsPresenter.unseenCount > 0 {
                    self.tabBarItem.badgeValue = String(notificationsPresenter.unseenCount)
                } else {
                    self.tabBarItem.badgeValue = nil
                }
                
                if self.isViewLoaded {
                    self.tableView.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            }
        }
    }
}

// MARK: - Table View

extension NotificationsViewController {
    
    private func setupTableView() {
        tableView.register(cellType: NotificationTableViewCell.self)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addValueChangedAction { [weak self] _ in self?.load() }
        tableView.refreshControl = refreshControl
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as NotificationTableViewCell
        
        if let item = presenter?.items[indexPath.row], let first = item.activities.first {
            var title = first.actor.name
            
            if item.activitiesCount > 1 {
                title += " and \(item.activitiesCount - 1) others"
            }
            
            if item.verb == .like {
                cell.title(with: title, subtitle: "liked your post")
            } else if item.verb == .follow {
                cell.title(with: title, subtitle: "followed you")
            }
            
            first.actor.loadAvatar { [weak cell] in cell?.avatarImageView?.image = $0 }
            cell.dateLabel.text = item.created.relative
            cell.isUnseen = !item.isSeen
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
