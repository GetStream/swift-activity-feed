//
//  FeedViewController.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 17/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import GetStream

open class FlatFeedViewController: UITableViewController, BundledStoryboardLoadable {
    
    open var presenter: FlatFeedPresenter<CustomActivity>?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        tabBarItem = UITabBarItem(title: "Home", image: .homeIcon, tag: 0)
        
        refreshControl = UIRefreshControl()
        
        refreshControl?.addAction(for: .valueChanged) { [weak self] _ in
            self?.reloadData()
        }
        
        reloadData()
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
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.activities.count ?? 0
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell(style: .subtitle, reuseIdentifier: "default")
    }
    
    override open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let presenter = presenter,
            indexPath.row < presenter.activities.count else {
            return
        }
        
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        
        let activity = presenter.activities[indexPath.row]
        cell.textLabel?.text = "\(activity.actor.name): \(activity.text ?? activity.object)"
        cell.detailTextLabel?.text = activity.attachments?.openGraphData?.description
    }
}
