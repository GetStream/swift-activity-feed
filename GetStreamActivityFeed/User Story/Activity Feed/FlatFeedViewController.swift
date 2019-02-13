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
        tableView.registerPostCells()
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
    
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let postDetailTableViewController = segue.destination as? PostDetailTableViewController,
            let activityPresenter = sender as? ActivityPresenter<Activity> else {
            return
        }
        
        postDetailTableViewController.activityPresenter = activityPresenter
    }
    
    private func activityPresenter(in section: Int) -> ActivityPresenter<Activity>? {
        if let presenter = presenter, section < presenter.count {
            return presenter.items[section]
        }
        
        return nil
    }
    
    func reloadData() {
        presenter?.load(completion: dataLoaded)
    }
    
    func dataLoaded(_ error: Error?) {
        refreshControl?.endRefreshing()
        
        if let error = error {
            showErrorAlert(error)
        } else {
            tableView.reloadData()
        }
    }
}

// MARK: - Table View

extension FlatFeedViewController {
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        guard let presenter = presenter else {
            return 0
        }
        
        return presenter.count + (presenter.hasNext ? 1 : 0)
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityPresenter(in: section)?.cellsCount ?? 1
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let activityPresenter = activityPresenter(in: indexPath.section),
            let cell = tableView.postCell(at: indexPath, in: self, presenter: activityPresenter) else {
                if let presenter = presenter, presenter.hasNext {
                    presenter.loadNext(completion: dataLoaded)
                    return tableView.dequeueReusableCell(for: indexPath) as PaginationTableViewCell
                }
                
                return .unused
        }
        
        let activity = activityPresenter.activity
        
        if let cell = cell as? PostHeaderTableViewCell {
            cell.updateAvatar(with: activity) { [weak self, weak activity] _ in
                if let self = self,
                    let activity = activity,
                    let profileViewCotroller = self.profileBuilder?.profileViewController(user: activity.actor) {
                    profileViewCotroller.builder = self.profileBuilder
                    self.navigationController?.pushViewController(profileViewCotroller, animated: true)
                }
            }
        }
        
        return cell
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard  let activityPresenter = activityPresenter(in: indexPath.section) else {
            return
        }
        
        if indexPath.row == (activityPresenter.cellsCount - 3), let openGraph = activityPresenter.ogData {
            let viewController = WebViewController()
            viewController.url = openGraph.url
            viewController.title = openGraph.title
            present(UINavigationController(rootViewController: viewController), animated: true)
            return
        }
        
        performSegue(show: PostDetailTableViewController.self, sender: activityPresenter)
    }
    
    open override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return removeActivityAction != nil && indexPath.row == 0
    }
    
    open override func tableView(_ tableView: UITableView,
                                 commit editingStyle: UITableViewCell.EditingStyle,
                                 forRowAt indexPath: IndexPath) {
        guard let activityPresenter = activityPresenter(in: indexPath.section) else {
            return
        }
        
        if editingStyle == .delete, let removeActivityAction = removeActivityAction {
            removeActivityAction(activityPresenter.activity)
        }
    }
}

// MARK: - Refresh Control

extension FlatFeedViewController {
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addValueChangedAction { [weak self] _ in self?.reloadData() }
    }
}
