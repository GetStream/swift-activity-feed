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
import SnapKit

open class FlatFeedViewController<T: ActivityProtocol>: UIViewController, UITableViewDelegate, UITableViewDataSource
    where T.ActorType: UserProtocol & UserNameRepresentable & AvatarRepresentable,
    T.ReactionType == GetStream.Reaction<ReactionExtraData, T.ActorType> {
    
    public typealias RemoveActivityAction = (_ activity: T) -> Void
    
    public let tableView = UITableView(frame: .zero, style: .plain)
    public let refreshControl = UIRefreshControl(frame: .zero)
    public var bannerView: UIView & BannerViewProtocol = BannerView()
    private var subscriptionId: SubscriptionId?
    
    public var presenter: FlatFeedPresenter<T>? {
        didSet {
            subscriptionId = presenter?.subscriptionPresenter.subscribe { [weak self] in
                if let self = self, let response = try? $0.get() {
                    let newCount = response.newActivities.count
                    let deletedCount = response.deletedActivitiesIds.count
                    let text: String
                    
                    if newCount > 0 {
                        text = self.subscriptionNewItemsTitle(with: newCount)
                        self.tabBarItem.badgeValue = String(newCount)
                    } else if deletedCount > 0 {
                        text = self.subscriptionDeletedItemsTitle(with: deletedCount)
                        self.tabBarItem.badgeValue = String(deletedCount)
                    } else {
                        return
                    }
                    
                    self.bannerView.textLabel.text = text
                    self.bannerView.present(in: self)
                }
            }
        }
    }
    
    public var removeActivityAction: RemoveActivityAction?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        reloadData()
    }
    
    public func activityPresenter(in section: Int) -> ActivityPresenter<T>? {
        if let presenter = presenter, section < presenter.count {
            return presenter.items[section]
        }
        
        return nil
    }
    
    public func reloadData() {
        presenter?.load(completion: dataLoaded)
    }
    
    open func dataLoaded(_ error: Error?) {
        refreshControl.endRefreshing()
        bannerView.hide(from: nil)
        tabBarItem.badgeValue = nil
        
        if let error = error {
            print("❌", error)
        } else {
            tableView.reloadData()
        }
    }
    
    // MARK: - Table View
    
    open func setupTableView() {
        view.addSubview(tableView)
        tableView.registerPostCells()
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        // Add RefreshController.
        tableView.refreshControl = refreshControl
        refreshControl.addValueChangedAction { [weak self] _ in self?.reloadData() }
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        guard let presenter = presenter else {
            return 0
        }
        
        return presenter.count + (presenter.hasNext ? 1 : 0)
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityPresenter(in: section)?.cellsCount ?? 1
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let activityPresenter = activityPresenter(in: indexPath.section),
            let cell = tableView.postCell(at: indexPath, presenter: activityPresenter) else {
                if let presenter = presenter, presenter.hasNext {
                    presenter.loadNext(completion: dataLoaded)
                    return tableView.dequeueReusableCell(for: indexPath) as PaginationTableViewCell
                }
                
                return .unused
        }
        
        if let cell = cell as? PostHeaderTableViewCell {
            updateAvatar(in: cell, activity: activityPresenter.originalActivity)
        }
        
        if let cell = cell as? PostActionsTableViewCell {
            updateActions(in: cell, activityPresenter: activityPresenter)
        }
        
        return cell
    }
    
    open func updateAvatar(in cell: PostHeaderTableViewCell, activity: T) {
        cell.updateAvatar(with: activity.actor)
    }
    
    open func updateActions(in cell: PostActionsTableViewCell, activityPresenter: ActivityPresenter<T>) {
        cell.updateReply(commentsCount: activityPresenter.originalActivity.commentsCount)
        
        cell.updateLike(presenter: activityPresenter, userTypeOf: T.ActorType.self) {
            if let error = $0 {
                print("❌", error)
            }
        }
        
        if let feedId = FeedId.user {
            cell.updateRepost(presenter: activityPresenter, targetFeedId: feedId, userTypeOf: T.ActorType.self) {
                if let error = $0 {
                    print("❌", error)
                }
            }
        }
    }
    
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return removeActivityAction != nil && indexPath.row == 0
    }
    
    open func tableView(_ tableView: UITableView,
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

// MARK: - Subscription for Updates

extension FlatFeedViewController {
    open func subscriptionNewItemsTitle(with count: Int) -> String {
        return "You have \(count) new activities"
    }
    
    open func subscriptionDeletedItemsTitle(with count: Int) -> String {
        return "You have \(count) deleted activities"
    }
}
