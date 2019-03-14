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
    public struct SectionTypes: OptionSet {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let activity = SectionTypes(rawValue: 1 << 0)
        public static let likes = SectionTypes(rawValue: 1 << 1)
        public static let reposts = SectionTypes(rawValue: 1 << 2)
        public static let comments = SectionTypes(rawValue: 1 << 3)
    }
    
    fileprivate struct Section {
        let section: SectionTypes
        let count: Int
    }
    
    public let tableView: UITableView = UITableView(frame: .zero, style: .plain)
    public let refreshControl  = UIRefreshControl(frame: .zero)
    public let textToolBar = TextToolBar.textToolBar
    public var activityPresenter: ActivityPresenter<Activity>?
    public var reactionPaginator: ReactionPaginator<ReactionExtraData, User>?
    private var replyToComment: Reaction?
    private var sectionsIndex: [Int: Section] = [:]
    public var sections: SectionTypes = [.activity, .likes, .reposts, .comments]
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        updateSectionsIndex()
        tableView.reloadData()
        User.current?.loadAvatar { [weak self] in self?.setupCommentTextField(avatarImage: $0) }
        
        if let activityPresenter = activityPresenter {
            reactionPaginator = activityPresenter.reactionPaginator(activityId: activityPresenter.originalActivity.id,
                                                                    reactionKind: .comment)
            
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
            self.sectionsIndex = [:]
            return
        }
        
        let originalActivity = activityPresenter.originalActivity
        var sectionsIndex: [Int: Section] = [:]
        var index = 0
        
        if sections.contains(.activity) {
            sectionsIndex[index] = Section(section: .activity, count: activityPresenter.cellsCount - 1)
            index += 1
        }
        
        if sections.contains(.likes), originalActivity.likesCount > 0 {
            sectionsIndex[index] = Section(section: .likes, count: 1)
            index += 1
        }
        
        if sections.contains(.reposts), originalActivity.repostsCount > 0 {
            sectionsIndex[index] = Section(section: .reposts, count: originalActivity.repostsCount)
            index += 1
        }
        
        if sections.contains(.comments), let reactionPaginator = reactionPaginator {
            let count = reactionPaginator.count + (reactionPaginator.hasNext ? 1 : 0)
            sectionsIndex[index] = Section(section: .comments, count: count)
        }
        
        self.sectionsIndex = sectionsIndex
    }
}

// MARK: - Table View Data Source

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    open func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerPostCells()
        
        // Add RefreshController.
        tableView.refreshControl = refreshControl
        
        refreshControl.addValueChangedAction { [weak self] _ in
            if let self = self {
                self.reactionPaginator?.load(completion: self.commentsLoaded)
            }
        }
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsIndex.count
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionsIndex[section]?.count ?? 0
//        guard let activityPresenter = activityPresenter, let reactionPaginator = reactionPaginator else {
//            return 0
//        }
//
//        let originalActivity = activityPresenter.originalActivity
//
//        switch section {
//        case 0: return activityPresenter.cellsCount - 1
//        case 1: return originalActivity.likesCount > 0 ? 1 : 0
//        case 2: return originalActivity.repostsCount
//        default: break
//        }
//
//        let commentIndex = section - 3
//
//        if commentIndex < reactionPaginator.items.count {
//            let reaction = reactionPaginator.items[commentIndex]
//            let childCommentsCount = (reaction.childrenCounts[.comment] ?? 0) > 0 ? 1 : 0
//            return 1 + childCommentsCount
//        }
//
//        return 1
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeader(in: section)
    }
    
    open func sectionHeader(in section: Int) -> String? {
        guard let originalActivity = activityPresenter?.originalActivity else {
            return nil
        }
        
        switch section {
        case 1: return originalActivity.likesCount > 0 ? "Liked (\(originalActivity.likesCount))" : nil
        case 2: return originalActivity.repostsCount > 0 ? "Reposts (\(originalActivity.repostsCount))" : nil
        case 3: return originalActivity.commentsCount > 0 ? "Comments (\(originalActivity.commentsCount))" : nil
        default: return nil
        }
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let activityPresenter = activityPresenter, let reactionPaginator = reactionPaginator else {
            return .unused
        }
        
        switch indexPath.section {
        case 0:
            if let cell = tableView.postCell(at: indexPath, presenter: activityPresenter) {
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
        case 1:
            let cell = tableView.dequeueReusableCell(for: indexPath) as ActionUsersTableViewCell
            cell.titleLabel.text = activityPresenter.reactionTitle(for: activityPresenter.originalActivity,
                                                                   kindOf: .like,
                                                                   suffix: "liked the post")
            
            cell.avatarsStackView.loadImages(with:
                activityPresenter.reactionUserAvatarURLs(for: activityPresenter.originalActivity, kindOf: .like))
            
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(for: indexPath) as ActionUsersTableViewCell
            cell.titleLabel.text = activityPresenter.reactionTitle(for: activityPresenter.originalActivity,
                                                                   kindOf: .repost,
                                                                   suffix: "reposted the post")
            
            cell.avatarsStackView.loadImages(with:
                activityPresenter.reactionUserAvatarURLs(for: activityPresenter.originalActivity, kindOf: .repost))
            
            return cell
            
        default: break
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
                let count = parentComment.childrenCounts[.comment], count > 1 {
                cell.moreReplies = "\(count - 1) more replies"
            }
        }
        
        return cell
    }
    
    open func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard indexPath.section == 0, let activityPresenter = activityPresenter else {
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
        
        if indexPath.row == 0, case .image(let url) = activityPresenter.activity.object {
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
            return
        }
        
        if indexPath.row == (cellsCount - 3) {
            if let ogData = activityPresenter.originalActivity.ogData {
                showOpenGraphData(with: ogData)
            } else {
                showImageGallery(with: activityPresenter.originalActivity.attachmentImageURLs())
            }
            return
        }
    }
}

// MARK: - Table View - Comments

extension DetailViewController {
    
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let comment = comment(at: indexPath), let currentUser = User.current else {
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
    
    private func comment(at indexPath: IndexPath) -> Reaction? {
        guard indexPath.section > 2 else {
            return nil
        }
        
        let commentIndex = indexPath.section - 3
        
        guard let reactionPaginator = reactionPaginator, commentIndex < reactionPaginator.count else {
            return nil
        }
        
        let comment = reactionPaginator.items[commentIndex]
        
        if indexPath.row > 0, let childComment = comment.latestChildren[.comment]?.first {
            return childComment
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
                button.like(activityPresenter.activity,
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
            tableView.reloadData()
        }
    }
}
