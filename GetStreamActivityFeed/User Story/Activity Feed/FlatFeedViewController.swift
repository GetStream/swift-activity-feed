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
    
    var subscriptionId: SubscriptionId?
    let bannerView = BannerView()
    
    var presenter: FlatFeedPresenter<Activity>? {
        didSet {
            subscriptionId = presenter?.subscriptionPresenter.subscribe { [weak self] in
                if let self = self, let response = try? $0.get() {
                    self.bannerView.textLabel.text = "You have \(response.newActivities.count) new activities"
                    self.bannerView.present(in: self)
                }
            }
        }
    }
    
    var notificationsPresenter: NotificationsPresenter<Activity>?
    var notificationsSubscriptionId: SubscriptionId?
    var profileBuilder: ProfileBuilder?
    var removeActivityAction: RemoveActivityAction?
    
    private lazy var activityRouter: ActivityRouter? = {
        if let profileBuilder = profileBuilder {
            let activityRouter = ActivityRouter(viewController: self, profileBuilder: profileBuilder)
            return activityRouter
        }
        
        return nil
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        tabBarItem = UITabBarItem(title: "Home", image: .homeIcon, tag: 0)
        hideBackButtonTitle()
        tableView.registerPostCells()
        setupRefreshControl()
        setupBellButton()
        reloadData()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateBellCounter()
        
        if parent == nil || parent is UINavigationController {
            navigationController?.restoreDefaultNavigationBar(animated: animated)
            reloadData()
        }
    }
    
    @IBAction func showEditPost(_ sender: Any) {
        performSegue(show: EditPostViewController.self, sender: nil)
    }
    
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let editPostnavigationController = segue.destination as? UINavigationController,
            let editPostViewController = editPostnavigationController.viewControllers.first as? EditPostViewController,
            let presenter = presenter {
            editPostViewController.presenter = EditPostPresenter(flatFeed: presenter.flatFeed, view: editPostViewController)
            return
        }
        
        guard let postDetailTableViewController = segue.destination as? PostDetailTableViewController,
            let activityPresenter = sender as? ActivityPresenter<Activity> else {
            return
        }
        
        postDetailTableViewController.activityPresenter = activityPresenter
        postDetailTableViewController.profileBuilder = profileBuilder
        postDetailTableViewController.feedId = FeedId(feedSlug: "user")
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
        bannerView.hide(from: self)
        
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
            let cell = tableView.postCell(at: indexPath,
                                          in: self,
                                          presenter: activityPresenter,
                                          feedId: FeedId(feedSlug: "user")) else {
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
        guard let activityPresenter = activityPresenter(in: indexPath.section) else {
            return
        }
        
        let cellsCount = activityPresenter.cellsCount
        
        if indexPath.row != 0 {
            if indexPath.row == (cellsCount - 4) {
                activityRouter?.show(attachmentImageURLs: activityPresenter.attachmentImageURLs(withObjectImage: true))
                return
            }
            
            if indexPath.row == (cellsCount - 3) {
                if let ogData = activityPresenter.ogData {
                    activityRouter?.show(ogData: ogData)
                } else {
                    activityRouter?.show(attachmentImageURLs: activityPresenter.attachmentImageURLs(withObjectImage: true))
                }
                return
            }
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

// MARK: - Bell Button

extension FlatFeedViewController {
    func setupBellButton() {
        guard let notificationsPresenter = notificationsPresenter else {
            return
        }
        
        let bellButton = BellButton()
        bellButton.addTap { [weak self] _ in self?.tabBarController?.selectTab(with: NotificationsViewController.self) }
        
        notificationsSubscriptionId = notificationsPresenter.subscriptionPresenter.subscribe { [weak bellButton] in
            if let response = try? $0.get() {
                bellButton?.count += response.newActivities.count
            } else {
                bellButton?.count = 0
            }
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: bellButton)
    }
    
    func updateBellCounter() {
        guard let notificationsViewController = tabBarController?.find(viewControllerType: NotificationsViewController.self),
            let bellButton = navigationItem.leftBarButtonItem?.customView as? BellButton else {
            return
        }
        
        bellButton.count = notificationsViewController.badgeValue
    }
}
