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
import SnapKit

/// A flat feed view controller.
open class FlatFeedViewController<T: ActivityProtocol>: BaseFlatFeedViewController<T>, UITableViewDelegate
    where T.ActorType: UserProtocol & UserNameRepresentable & AvatarRepresentable,
    T.ReactionType == GetStream.Reaction<ReactionExtraData, T.ActorType> {
    
    /// A block type for the removing of an action.
    public typealias RemoveActivityAction = (_ activity: T) -> Void
    /// A banner view to show realtime updates. See `BannerView`.
    public var bannerView: UIView & BannerViewProtocol = BannerView.make()
    private var subscriptionId: SubscriptionId?
    /// A flat feed presenter for the presentation logic.
    public var presenter: FlatFeedPresenter<T>?
    /// A block for the removing of an action.
    public var removeActivityAction: RemoveActivityAction?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        reloadData()
        
        bannerView.addTap { [weak self] in
            $0.hide()
            self?.reloadData()
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: animated)
        }
    }
    
    /// Returns the activity presenter by the table section.
    public func activityPresenter(in section: Int) -> ActivityPresenter<T>? {
        if let presenter = presenter, section < presenter.count {
            return presenter.items[section]
        }
        
        return nil
    }
    
    open override func reloadData() {
        presenter?.load(completion: dataLoaded)
    }
    
    open override func dataLoaded(_ error: Error?) {
        bannerView.hide()
        tabBarItem.badgeValue = nil
        super.dataLoaded(error)
    }
    
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
            let cell = tableView.postCell(at: indexPath, presenter: activityPresenter) else {
                if let presenter = presenter, presenter.hasNext {
                    presenter.loadNext(completion: dataLoaded)
                    return tableView.dequeueReusableCell(for: indexPath) as PaginationTableViewCell
                }
                
                return .unused
        }
        
        if let cell = cell as? PostHeaderTableViewCell {
            updateAvatar(in: cell, activity: activityPresenter.originalActivity)
        } else if let cell = cell as? PostActionsTableViewCell {
            updateActions(in: cell, activityPresenter: activityPresenter)
        }
        
        return cell
    }
    
    open override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return removeActivityAction != nil && indexPath.row == 0
    }
    
    open override func tableView(_ tableView: UITableView,
                                 commit editingStyle: UITableViewCell.EditingStyle,
                                 forRowAt indexPath: IndexPath) {
        if editingStyle == .delete,
            let removeActivityAction = removeActivityAction,
            let activityPresenter = activityPresenter(in: indexPath.section) {
            removeActivityAction(activityPresenter.activity)
        }
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cellType = activityPresenter(in: indexPath.section)?.cellType(at: indexPath.row) else {
            return
        }
        
        if case .attachmentImages(let urls) = cellType {
            showImageGallery(with: urls)
        } else if case .attachmentOpenGraphData(let ogData) = cellType {
            showOpenGraphData(with: ogData)
        }
    }
}

// MARK: - Subscription for Updates

extension FlatFeedViewController {
    
    /// Subscribes for the realtime updates.
    open func subscribeForUpdates() {
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
                
                self.bannerView.show(text, in: self)
            }
        }
    }
    
    /// Unsubscribes from the realtime updates.
    public func unsubscribeFromUpdates() {
        subscriptionId = nil
    }
    
    /// Return a title of new activies for the banner view on updates.
    open func subscriptionNewItemsTitle(with count: Int) -> String {
        return "You have \(count) new activit\(count == 1 ? "y" : "ies")"
    }
    
    /// Return a title of removed activities for the banner view on updates.
    open func subscriptionDeletedItemsTitle(with count: Int) -> String {
        return "You have \(count) deleted activit\(count == 1 ? "y" : "ies")"
    }
}
