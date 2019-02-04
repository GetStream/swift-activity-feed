//
//  PostDetailTableViewController.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 01/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import SnapKit

open class PostDetailTableViewController: UITableViewController {
    
    var activityPresenter: ActivityPresenter<Activity>?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerPostCells()
    }
}

// MARK: - Table view data source

extension PostDetailTableViewController {
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let activityPresenter = activityPresenter else {
            return 0
        }
        
        switch section {
        case 0: return activityPresenter.cellsCount - 1
        case 1: return activityPresenter.activity.originalActivity.likesCount > 0 ? 1 : 0
        case 2: return activityPresenter.activity.originalActivity.repostsCount
        case 3: return activityPresenter.activity.originalActivity.commentsCount
        default: return 0
        }
    }
    
    open override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title: String
        
        switch section {
        case 1: title = "Liked"
        case 2: title = "Reposts"
        case 3: title = "Comments"
        default: return nil
        }
        
        let view = UIView(frame: .zero)
        view.backgroundColor = Appearance.Color.lightGray
        
        let label = UILabel(frame: .zero)
        label.textColor = .gray
        label.attributedText = NSAttributedString(string: title.uppercased(), attributes: Appearance.headerTextAttributes())
        view.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.top.bottom.equalToSuperview()
        }
        
        return view
    }
    
    open override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 30
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let activityPresenter = activityPresenter else {
            return .unused
        }
        
        switch indexPath.section {
        case 0:
            if let cell = tableView.postCell(at: indexPath, in: self, type: .detail, presenter: activityPresenter) {
                if let cell = cell as? PostHeaderTableViewCell {
                    cell.updateAvatar(with: activityPresenter.activity)
                }
                
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCell(for: indexPath) as ActionUsersTableViewCell
            cell.titleLabel.text = activityPresenter.likedTitle
            return cell
        default:
            break
        }
        
        return .unused
    }
    
    open override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 && activityPresenter?.ogData != nil
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let openGraph = activityPresenter?.ogData {
            let viewController = WebViewController()
            viewController.url = openGraph.url
            viewController.title = openGraph.title
            present(UINavigationController(rootViewController: viewController), animated: true)
        }
    }
}
