//
//  DetailViewController.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 01/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import SnapKit
import GetStream

// MARK: - Detail View Controller Section Type

public struct DetailViewControllerSectionTypes: OptionSet, Equatable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let activity = DetailViewControllerSectionTypes(rawValue: 1 << 0)
    public static let likes = DetailViewControllerSectionTypes(rawValue: 1 << 1)
    public static let reposts = DetailViewControllerSectionTypes(rawValue: 1 << 2)
    public static let comments = DetailViewControllerSectionTypes(rawValue: 1 << 3)
}

// MARK: - Detail View Controller Section

public struct DetailViewControllerSection {
    let section: DetailViewControllerSectionTypes
    let title: String?
    let count: Int
}

// MARK: - Detail View Controller

open class DetailViewController<T: ActivityProtocol>: BaseFlatFeedViewController<T>, UITableViewDelegate, UITextViewDelegate
    where T.ActorType: UserProtocol & UserNameRepresentable & AvatarRepresentable,
          T.ReactionType == GetStream.Reaction<ReactionExtraData, T.ActorType> {
    
    public let textToolBar = TextToolBar.make()
    public var reactionPaginator: ReactionPaginator<ReactionExtraData, T.ActorType>?
    private var replyToComment: T.ReactionType?
    public private(set) var sectionsData: [DetailViewControllerSection] = []
    public var sections: DetailViewControllerSectionTypes = .activity
    public var childCommentsCount = 0
    public var canAddComment = true
    
    public var activityPresenter: ActivityPresenter<T>? {
        didSet {
            if let activityPresenter = activityPresenter {
                reactionPaginator = activityPresenter.reactionPaginator(activityId: activityPresenter.originalActivity.id,
                                                                        reactionKind: .comment)
            }
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        updateSectionsIndex()
        
        if sections.contains(.comments) {
            reactionPaginator?.load(completion: commentsLoaded)
            
            if canAddComment {
                User.current?.loadAvatar { [weak self] in self?.setupCommentTextField(avatarImage: $0) }
            }
        }
        
        reloadData()
        
        if isModal {
            setupNavigationBarForModallyPresented()
        }
    }
    
    private func updateSectionsIndex() {
        guard let activityPresenter = activityPresenter else {
            self.sectionsData = []
            return
        }
        
        let originalActivity = activityPresenter.originalActivity
        var sectionsData: [DetailViewControllerSection] = []
        
        if sections.contains(.activity) {
            sectionsData.append(DetailViewControllerSection(section: .activity, title: nil, count: activityPresenter.cellsCount - 1))
        }
        
        if sections.contains(.likes), originalActivity.likesCount > 0 {
            let title = sectionTitle(for: .likes, count: originalActivity.likesCount)
            sectionsData.append(DetailViewControllerSection(section: .likes, title: title, count: 1))
        }
        
        if sections.contains(.reposts), originalActivity.repostsCount > 0 {
            let title = sectionTitle(for: .reposts, count: originalActivity.repostsCount)
            sectionsData.append(DetailViewControllerSection(section: .reposts, title: title, count: originalActivity.repostsCount))
        }
        
        if sections.contains(.comments), let reactionPaginator = reactionPaginator {
            let title = sectionTitle(for: .comments, count: reactionPaginator.count)
            sectionsData.append(DetailViewControllerSection(section: .comments, title: title, count: reactionPaginator.count))
        }
        
        self.sectionsData = sectionsData
    }
    
    open func sectionTitle(for type: DetailViewControllerSectionTypes, count: Int) -> String? {
        if type == .likes {
            return "Liked (\(count))"
        }
        
        if type == .reposts {
            return "Reposts (\(count))"
        }
        
        if type == .comments {
            return "Comments (\(count))"
        }
        
        return nil
    }
    
    public func sectionTitle(in section: Int) -> String? {
        return section < sectionsData.count ? sectionsData[section].title : nil
    }
    
    // MARK: - Table View Data Source
    
    open override func setupTableView() {
        tableView.delegate = self
        
        if canAddComment, sections.contains(.comments) {
            tableView.snp.makeConstraints { $0.left.top.right.equalToSuperview() }
        } else {
            tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        }
    }
    
    open override func setupRefreshControl() {
        if sections.contains(.comments) {
            tableView.refreshControl = refreshControl
            
            refreshControl.addValueChangedAction { [weak self] _ in
                if let self = self, let reactionPaginator = self.reactionPaginator {
                    reactionPaginator.load(completion: self.commentsLoaded)
                }
            }
        }
    }
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        guard sectionsData.count > 0 else {
            return 0
        }
        
        var count = sectionsData.count
        
        if sections.contains(.comments), let reactionPaginator = reactionPaginator {
            count -= 1 // remove the comments section from sectionsData, the rest of the sections are comments.
            count += reactionPaginator.count + (reactionPaginator.hasNext ? 1 : 0)
        }
        
        return count
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < sectionsData.count, sectionsData[section].section != .comments {
            return sectionsData[section].count
        }
        
        guard sections.contains(.comments), let reactionPaginator = reactionPaginator else {
            return 0
        }
        
        guard childCommentsCount > 0 else {
            return 1
        }
        
        let commentIndex = self.commentIndex(in: section)
        
        if commentIndex < reactionPaginator.items.count {
            let comment = reactionPaginator.items[commentIndex]
            let childCommentsCount = comment.childrenCounts[.comment] ?? 0
            return min(childCommentsCount, self.childCommentsCount) + 1
        }
        
        return 1
    }
    
    open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section < sectionsData.count && sectionsData.count != 1 ? sectionsData[section].title : nil
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let activityPresenter = activityPresenter, let reactionPaginator = reactionPaginator else {
            return .unused
        }
        
        if indexPath.section < sectionsData.count {
            let section = sectionsData[indexPath.section]
            
            if section.section == .activity, let cell = tableView.postCell(at: indexPath, presenter: activityPresenter) {
                if let cell = cell as? PostHeaderTableViewCell {
                    updateAvatar(in: cell, activity: activityPresenter.originalActivity)
                }
                
                if let cell = cell as? PostActionsTableViewCell {
                    updateActions(in: cell, activityPresenter: activityPresenter)
                }
                
                return cell
            }
            
            if section.section == .likes {
                let cell = tableView.dequeueReusableCell(for: indexPath) as ActionUsersTableViewCell
                cell.titleLabel.text = activityPresenter.reactionTitle(for: activityPresenter.originalActivity,
                                                                       kindOf: .like,
                                                                       suffix: "liked the post")
                
                cell.avatarsStackView.loadImages(with:
                    activityPresenter.reactionUserAvatarURLs(for: activityPresenter.originalActivity, kindOf: .like))
                
                return cell
            }
            
            if section.section == .reposts {
                let cell = tableView.dequeueReusableCell(for: indexPath) as ActionUsersTableViewCell
                cell.titleLabel.text = activityPresenter.reactionTitle(for: activityPresenter.originalActivity,
                                                                       kindOf: .repost,
                                                                       suffix: "reposted the post")
                
                cell.avatarsStackView.loadImages(with:
                    activityPresenter.reactionUserAvatarURLs(for: activityPresenter.originalActivity, kindOf: .repost))
                
                return cell
            }
        }
        
        guard let comment = comment(at: indexPath) else {
            reactionPaginator.loadNext(completion: commentsLoaded)
            return tableView.dequeueReusableCell(for: indexPath) as PaginationTableViewCell
        }
        
        let cell = tableView.dequeueReusableCell(for: indexPath) as CommentTableViewCell
        update(cell: cell, with: comment)
        
        if indexPath.row > 0 {
            cell.withIndent = true
            
            if let parentComment = self.comment(at: IndexPath(row: 0, section: indexPath.section)),
                let count = parentComment.childrenCounts[.comment],
                count > childCommentsCount,
                indexPath.row == childCommentsCount {
                cell.moreReplies = moreCommentsTitle(with: count - childCommentsCount)
            }
        } else if childCommentsCount == 0, let childCount = comment.childrenCounts[.comment], childCount > 0 {
            cell.moreReplies = moreCommentsTitle(with: childCount)
        }
        
        return cell
    }
    
    open func moreCommentsTitle(with count: Int) -> String {
        return "\(count) more replies"
    }
    
    // MARK: - Table View - Select Cell
    
    open func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let activityPresenter = activityPresenter,
            indexPath.section < sectionsData.count,
            sectionsData[indexPath.section].section == .activity,
            let cellType = activityPresenter.cellType(at: indexPath) else {
                return false
        }
        
        if case .attachmentImages = cellType {
            return true
        } else if case .attachmentOpenGraphData = cellType {
            return true
        }
        
        return false
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let activityPresenter = activityPresenter,
            let cellType = activityPresenter.cellType(at: indexPath) else {
                return
        }
        
        if case .attachmentImages(let urls) = cellType {
            showImageGallery(with: urls)
        } else if case .attachmentOpenGraphData(let ogData) = cellType {
            showOpenGraphData(with: ogData)
        }
    }
    
    // MARK: - Table View - Comments
    
    open override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard sections.contains(.comments), let currentUser = User.current, let comment = comment(at: indexPath) else {
            return false
        }
        
        return comment.user.id == currentUser.id
    }
    
    open override func tableView(_ tableView: UITableView,
                                 commit editingStyle: UITableViewCell.EditingStyle,
                                 forRowAt indexPath: IndexPath) {
        if editingStyle == .delete,
            let activityPresenter = activityPresenter,
            let comment = comment(at: indexPath),
            let parentComment = self.comment(at: IndexPath(row: 0, section: indexPath.section)) {
            if comment == parentComment {
                activityPresenter.reactionPresenter.remove(reaction: comment, activity: activityPresenter.activity) { [weak self] in
                    if let error = $0.error {
                        self?.showErrorAlert(error)
                    } else if let self = self{
                        self.reactionPaginator?.load(completion: self.commentsLoaded)
                    }
                }
            } else {
                activityPresenter.reactionPresenter.remove(reaction: comment, parentReaction: parentComment) { [weak self] in
                    if let error = $0.error {
                        self?.showErrorAlert(error)
                    } else {
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func commentIndex(in section: Int) -> Int {
        if section < sectionsData.count, sectionsData[section].section != .comments {
            return -1
        }
        
        return section - (sectionsData.count > 0 ? (sectionsData.count - 1) : 0)
    }
    
    private func comment(at indexPath: IndexPath) -> GetStream.Reaction<ReactionExtraData, T.ActorType>? {
        let commentIndex = self.commentIndex(in: indexPath.section)
        
        guard commentIndex >= 0, let reactionPaginator = reactionPaginator, commentIndex < reactionPaginator.count else {
            return nil
        }
        
        let comment = reactionPaginator.items[commentIndex]
        let childCommentIndex = indexPath.row - 1
        
        if childCommentIndex >= 0, let childComments = comment.latestChildren[.comment], childCommentIndex < childComments.count {
            return childComments[childCommentIndex]
        }
        
        return comment
    }
    
    private func update(cell: CommentTableViewCell, with comment: GetStream.Reaction<ReactionExtraData, T.ActorType>) {
        guard case .comment(let text) = comment.data else {
            return
        }
        
        cell.updateComment(name: comment.user.name, comment: text, date: comment.created)
        comment.user.loadAvatar { [weak cell] in cell?.avatarImageView?.image = $0 }
        
        // Reply button.
        cell.replyButton.addTap { [weak self] _ in
            if let self = self, case .comment(let text) = comment.data {
                self.replyToComment = comment
                self.textToolBar.replyText = "Reply to \(comment.user.name): \(text)"
                self.textToolBar.textView.becomeFirstResponder()
            }
        }
        
        // Like button.
        let countTitle = comment.childrenCounts[.like] ?? 0
        cell.likeButton.setTitle(countTitle == 0 ? "" : String(countTitle), for: .normal)
        cell.likeButton.isSelected = comment.hasUserOwnChildReaction(.like)
        
        cell.likeButton.addTap { [weak self] in
            if let activityPresenter = self?.activityPresenter, let button = $0 as? LikeButton {
                button.like(activityPresenter.originalActivity,
                            presenter: activityPresenter.reactionPresenter,
                            likedReaction: comment.userOwnChildReaction(.like),
                            parentReaction: comment,
                            userTypeOf: T.ActorType.self) { _ in }
            }
        }
    }
    
    private func commentsLoaded(_ error: Error?) {
        refreshControl.endRefreshing()
        
        if let error = error {
            showErrorAlert(error)
        } else {
            updateSectionsIndex()
            tableView.reloadData()
        }
    }
    
    // MARK: - Comment Text Field
    
    private func setupCommentTextField(avatarImage: UIImage?) {
        textToolBar.placeholderText = "Leave reply"
        textToolBar.addToSuperview(view)
        textToolBar.avatarView.image = avatarImage
        textToolBar.sendButton.addTarget(self, action: #selector(send(_:)), for: .touchUpInside)
        
        tableView.snp.makeConstraints { make in
            make.bottom.equalTo(textToolBar.snp.top)
        }
    }
    
    @objc func send(_ button: UIButton) {
        let parentReaction = textToolBar.replyText == nil ? nil : replyToComment
        view.endEditing(true)
        
        guard !textToolBar.text.isEmpty, let activityPresenter = activityPresenter else {
            return
        }
        
        textToolBar.textView.isEditable = false
        
        activityPresenter.reactionPresenter.addComment(for: activityPresenter.activity,
                                                       parentReaction: parentReaction,
                                                       extraData: ReactionExtraData.comment(textToolBar.text),
                                                       userTypeOf: T.ActorType.self) { [weak self] in
                                                        if let self = self {
                                                            self.textToolBar.text = ""
                                                            self.textToolBar.textView.isEditable = true
                                                            
                                                            if let error = $0.error {
                                                                self.showErrorAlert(error)
                                                            } else {
                                                                self.reactionPaginator?.load(completion: self.commentsLoaded)
                                                            }
                                                        }
        }
    }
}

// MARK: - Modally presented

extension DetailViewController {
    open func setupNavigationBarForModallyPresented() {
        guard navigationController != nil else {
            return
        }
        
        let closeButton = UIButton(type: .custom)
        closeButton.setImage(.closeIcon, for: .normal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        
        closeButton.addTap { [weak self] _ in
            self?.dismiss(animated: true)
        }
    }
}
