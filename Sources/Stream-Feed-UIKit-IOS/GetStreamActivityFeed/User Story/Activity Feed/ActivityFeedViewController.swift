//
//  ActivityFeedViewController.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 11/03/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import GetStream

public final class ActivityFeedViewController: FlatFeedViewController<Activity>, BundledStoryboardLoadable {
    public static var storyboardName = "ActivityFeed"
    
    var profileBuilder: ProfileBuilder?
    var notificationsPresenter: NotificationsPresenter<Activity>?
    var notificationsSubscriptionId: SubscriptionId?
    
    private lazy var activityRouter: ActivityRouter? = {
        if let profileBuilder = profileBuilder {
            let activityRouter = ActivityRouter(viewController: self, profileBuilder: profileBuilder)
            return activityRouter
        }
        
        return nil
    }()
    
    weak var backBtn: UIBarButtonItem? {
        let image = UIImage(named: "backArrow")
        let desiredImage = image
        let back = UIBarButtonItem(image: desiredImage, style: .plain, target: self, action: #selector(backBtnPressed(_:)))
        return back
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        subscribeForUpdates()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = UIColor.black
        navigationController?.navigationBar.setCustomTitleFont(font: UIFont(name: "GTWalsheimProBold", size: 18.0)!)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationItem.leftBarButtonItem = backBtn
        navigationItem.title = localizedNavigationTitle
    }
    
    @objc private func backBtnPressed(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if parent == nil || parent is UINavigationController {
            navigationController?.restoreDefaultNavigationBar(animated: animated)
        }
    }
    
    public override func dataLoaded(_ error: Error?) {
        super.dataLoaded(error)
        //showErrorAlertIfNeeded(error)
    }
    
    public override func updateAvatar(in cell: PostHeaderTableViewCell, activity: Activity) {
        cell.updateAvatar(with: activity.actor) { [weak self] _ in
            if let self = self,
                let profileViewCotroller = self.profileBuilder?.profileViewController(user: activity.actor) {
                profileViewCotroller.builder = self.profileBuilder
                self.navigationController?.pushViewController(profileViewCotroller, animated: true)
            }
        }
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let activityPresenter = activityPresenter(in: indexPath.section),
            let cellType = activityPresenter.cellType(at: indexPath.row) else {
            return
        }
        
        var showDetail = indexPath.row == 0 || indexPath.row == 1
        
        if !showDetail, case .actions = cellType {
            showDetail = true
        }
        
        if showDetail {
            performSegue(show: PostDetailTableViewController.self, sender: activityPresenter)
        } else {
            super.tableView(tableView, didSelectRowAt: indexPath)
        }
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.destination is EditPostViewController,
            let userFeedId = FeedId.user,
            let activity = sender as? Activity {
            let editPostViewController = segue.destination as! EditPostViewController
            editPostViewController.presenter = EditPostPresenter(flatFeed: Client.shared.flatFeed(userFeedId),
                                                                 view: editPostViewController, activity: activity)
            return
        }
        
        guard let activityDetailTableViewController = segue.destination as? PostDetailTableViewController,
              let activityPresenter = sender as? ActivityPresenter<Activity> else {
                return
        }
        activityDetailTableViewController.reportUserAction = reportUserAction
        activityDetailTableViewController.shareTimeLinePostAction = shareTimeLinePostAction
        activityDetailTableViewController.navigateToUserProfileAction = navigateToUserProfileAction
        activityDetailTableViewController.isCurrentUser = isCurrentUser
        activityDetailTableViewController.presenter = presenter
        activityDetailTableViewController.activityPresenter = activityPresenter
        activityDetailTableViewController.sections = [.activity, .comments]
    }
}

extension ActivityFeedViewController : UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return (navigationController?.viewControllers.count ?? 0) > 1
    }
    
    // This is necessary because without it, subviews of your top controller can
    // cancel out your gesture recognizer on the edge.
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
