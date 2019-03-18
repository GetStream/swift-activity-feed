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

open class DetailViewController: UIViewController {
    public struct SectionTypes: OptionSet, Equatable {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let activity = SectionTypes(rawValue: 1 << 0)
        public static let likes = SectionTypes(rawValue: 1 << 1)
        public static let reposts = SectionTypes(rawValue: 1 << 2)
        public static let comments = SectionTypes(rawValue: 1 << 3)
    }
    
    public struct Section {
        let section: SectionTypes
        let title: String?
        let count: Int
    }
    
    public let tableView: UITableView = UITableView(frame: .zero, style: .plain)
    public let refreshControl  = UIRefreshControl(frame: .zero)
    public let textToolBar = TextToolBar.textToolBar
    public var reactionPaginator: ReactionPaginator<ReactionExtraData, User>?
    private var replyToComment: Reaction?
    public private(set) var sectionsData: [Section] = []
    public var sections: SectionTypes = [.activity, .likes, .reposts, .comments]
    public var childCommentsCount = 0
    
    public var activityPresenter: ActivityPresenter<Activity>? {
        didSet {
            if let activityPresenter = activityPresenter {
                reactionPaginator = activityPresenter.reactionPaginator(activityId: activityPresenter.originalActivity.id,
                                                                        reactionKind: .comment)
            }
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        updateSectionsIndex()
        
        if sections.contains(.comments) {
            User.current?.loadAvatar { [weak self] in self?.setupCommentTextField(avatarImage: $0) }
            reactionPaginator?.load(completion: commentsLoaded)
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: animated)
        }
    }
    
    private func updateSectionsIndex() {
        guard let activityPresenter = activityPresenter else {
            self.sectionsData = []
            return
        }
        
        let originalActivity = activityPresenter.originalActivity
        var sectionsData: [Section] = []
        
        if sections.contains(.activity) {
            sectionsData.append(Section(section: .activity, title: nil, count: activityPresenter.cellsCount - 1))
        }
        
        if sections.contains(.likes), originalActivity.likesCount > 0 {
            let title = sectionTitle(for: .likes, count: originalActivity.likesCount)
            sectionsData.append(Section(section: .likes, title: title, count: 1))
        }
        
        if sections.contains(.reposts), originalActivity.repostsCount > 0 {
            let title = sectionTitle(for: .reposts, count: originalActivity.repostsCount)
            sectionsData.append(Section(section: .reposts, title: title, count: originalActivity.repostsCount))
        }
        
        if sections.contains(.comments), let reactionPaginator = reactionPaginator {
            let title = sectionTitle(for: .comments, count: reactionPaginator.count)
            sectionsData.append(Section(section: .comments, title: title, count: reactionPaginator.count))
        }
        
        self.sectionsData = sectionsData
    }
    
    open func sectionTitle(for type: SectionTypes, count: Int) -> String? {
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
}

// MARK: - Table View Data Source

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    open func setupTableView() {
        view.addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerPostCells()
        
        if sections.contains(.comments) {
            tableView.snp.makeConstraints { $0.left.top.right.equalToSuperview() }
            tableView.refreshControl = refreshControl
            
            refreshControl.addValueChangedAction { [weak self] _ in
                if let self = self, let reactionPaginator = self.reactionPaginator {
                    reactionPaginator.load(completion: self.commentsLoaded)
                }
            }
        } else {
            tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        }
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
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
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section < sectionsData.count ? sectionsData[section].title : nil
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let activityPresenter = activityPresenter, let reactionPaginator = reactionPaginator else {
            return .unused
        }
        
        if indexPath.section < sectionsData.count {
            let section = sectionsData[indexPath.section]
            
            if section.section == .activity, let cell = tableView.postCell(at: indexPath, presenter: activityPresenter) {
                if let cell = cell as? PostActionsTableViewCell {
                    cell.updateReply(commentsCount: activityPresenter.originalActivity.commentsCount)
                    cell.updateLike(presenter: activityPresenter, userTypeOf: User.self, showErrorAlertIfNeeded)
                    
                    if let feedId = FeedId.user {
                        cell.updateRepost(presenter: activityPresenter,
                                          targetFeedId: feedId,
                                          userTypeOf: User.self,
                                          showErrorAlertIfNeeded)
                    }
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
}

// MARK: - Table View - Select Cell

extension DetailViewController {
    
    open func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let activityPresenter = activityPresenter,
            indexPath.section < sectionsData.count,
            sectionsData[indexPath.section].section == .activity else {
                return false
        }
        
        let cellsCount = activityPresenter.cellsCount
        
        if indexPath.row == 0, case .image = activityPresenter.activity.object {
            return true
        }
        
        return indexPath.row == (cellsCount - 4) || indexPath.row == (cellsCount - 3)
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let activityPresenter = activityPresenter else {
            return
        }
        
        if case .image(let url) = activityPresenter.originalActivity.object {
            var urls = [url]
            
            if let attachmentURLs = activityPresenter.originalActivity.attachmentImageURLs() {
                urls.append(contentsOf: attachmentURLs)
            }
            
            showImageGallery(with: urls)
            return
        }
        
        let cellsCount = activityPresenter.cellsCount
        
        if indexPath.row == (cellsCount - 4) {
            showImageGallery(with: activityPresenter.originalActivity.attachmentImageURLs())
        } else if indexPath.row == (cellsCount - 3) {
            if let ogData = activityPresenter.originalActivity.ogData {
                showOpenGraphData(with: ogData)
            } else {
                showImageGallery(with: activityPresenter.originalActivity.attachmentImageURLs())
            }
        }
    }
}

// MARK: - Table View - Comments

extension DetailViewController {
    
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard sections.contains(.comments), let currentUser = User.current, let comment = comment(at: indexPath) else {
            return false
        }
        
        return comment.user.id == currentUser.id
    }
    
    open func tableView(_ tableView: UITableView,
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
    
    private func comment(at indexPath: IndexPath) -> Reaction? {
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
    
    private func update(cell: CommentTableViewCell, with comment: Reaction) {
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
                            userTypeOf: User.self) { _ in }
            }
        }
    }
}

// MARK: - Comment Text Field

extension DetailViewController: UITextViewDelegate {
    private func setupCommentTextField(avatarImage: UIImage?) {
        textToolBar.placeholderText = "Leave reply"
        textToolBar.addToSuperview(view)
        textToolBar.textView.delegate = self
        textToolBar.avatarView.image = avatarImage
        textToolBar.sendButton.addTarget(self, action: #selector(send(_:)), for: .touchUpInside)
        
        tableView.snp.makeConstraints { make in
            make.bottom.equalTo(textToolBar.snp.top)
        }
    }
    
    @objc func send(_ button: UIButton) {
        let parentReaction: Reaction? = textToolBar.replyText == nil ? nil : replyToComment
        view.endEditing(true)
        textToolBar.clearPlaceholder()
        
        guard let text = textToolBar.textView.text, !text.isEmpty, let activityPresenter = activityPresenter else {
            return
        }
        
        textToolBar.textView.text = nil
        textToolBar.addPlaceholder()
        textToolBar.textView.isEditable = false
        
        activityPresenter.reactionPresenter.addComment(for: activityPresenter.activity,
                                                       parentReaction: parentReaction,
                                                       extraData: ReactionExtraData.comment(text),
                                                       userTypeOf: User.self) { [weak self] in
                                                        if let self = self {
                                                            self.textToolBar.textView.isEditable = true
                                                            
                                                            if let error = $0.error {
                                                                self.showErrorAlert(error)
                                                            } else {
                                                                self.reactionPaginator?.load(completion: self.commentsLoaded)
                                                            }
                                                        }
        }
    }
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textToolBar.clearPlaceholder()
        return true
    }
    
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textToolBar.addPlaceholder()
        return true
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        textToolBar.updateSendButton()
        textToolBar.updateTextHeightIfNeeded()
    }
}

// MARK: - Comments Pagination

extension DetailViewController {
    private func commentsLoaded(_ error: Error?) {
        refreshControl.endRefreshing()
        
        if let error = error {
            showErrorAlert(error)
        } else {
            updateSectionsIndex()
            tableView.reloadData()
        }
    }
}
