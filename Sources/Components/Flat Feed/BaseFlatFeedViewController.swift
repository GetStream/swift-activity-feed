//
//  BaseFlatFeedViewController.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 18/03/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import GetStream

open class BaseFlatFeedViewController<T: ActivityProtocol>: UIViewController, UITableViewDataSource
    where T.ActorType: UserProtocol & UserNameRepresentable & AvatarRepresentable,
          T.ReactionType == GetStream.Reaction<ReactionExtraData, T.ActorType> {
    
    public private(set) lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.registerPostCells()
        view.addSubview(tableView)
        return tableView
    }()
    
    public let refreshControl = UIRefreshControl(frame: .zero)
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupRefreshControl()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: animated)
        }
    }
    
    open func setupTableView() {
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    open func setupRefreshControl() {
        tableView.refreshControl = refreshControl
        refreshControl.addValueChangedAction { [weak self] _ in self?.reloadData() }
    }
    
    open func reloadData() {}
    
    open func dataLoaded(_ error: Error?) {
        refreshControl.endRefreshing()
        
        if let error = error {
            print("❌", error)
        } else {
            tableView.reloadData()
        }
    }
    
    // MARK: - Table View Data Source
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return .unused
    }
    
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    }
    
    // MARK: - Cells
    
    open func updateAvatar(in cell: PostHeaderTableViewCell, activity: T) {
        cell.updateAvatar(with: activity.actor)
    }
    
    open func updateActions(in cell: PostActionsTableViewCell, activityPresenter: ActivityPresenter<T>) {
        if activityPresenter.reactionTypes.contains(.comments) {
            cell.updateReply(commentsCount: activityPresenter.originalActivity.commentsCount)
        }
        
        if activityPresenter.reactionTypes.contains(.likes) {
            cell.updateLike(presenter: activityPresenter, userTypeOf: T.ActorType.self) {
                if let error = $0 {
                    print("❌", error)
                }
            }
        }
        
        if activityPresenter.reactionTypes.contains(.reposts), let feedId = FeedId.user {
            cell.updateRepost(presenter: activityPresenter, targetFeedId: feedId, userTypeOf: T.ActorType.self) {
                if let error = $0 {
                    print("❌", error)
                }
            }
        }
    }
}
