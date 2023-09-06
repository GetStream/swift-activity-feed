//
//  PostHeaderTableViewCell.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 18/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import Nuke
import GetStream
import Kingfisher

open class PostHeaderTableViewCell: BaseTableViewCell {

    @IBOutlet public weak var avatarButton: UIButton!
    @IBOutlet public weak var nameLabel: UILabel!
    @IBOutlet private weak var repostInfoStackView: UIStackView!
    @IBOutlet private weak var repostInfoLabel: UILabel!
    @IBOutlet public weak var dateLabel: UILabel!
    @IBOutlet public weak var messageLabel: UILabel!
    @IBOutlet private weak var messageBottomConstraint: NSLayoutConstraint!
    @IBOutlet private(set) weak var photoImageView: UIImageView!
    @IBOutlet public weak var postSettingsButton: UIButton!
    @IBOutlet public weak var ImagePostButton: UIButton!
    
    var allImageURLs: [URL] = []
    var activityID: String = ""
    var postImageURL: URL?
    var postSettingsTapped: ((Activity) -> Void)?
    var photoImageTapped: ((URL) -> Void)?
    var profileImageTapped: ((String) -> Void)?
    var sendImageURLValues: ((URL) -> Void)?
    var currentActivity: Activity?
    
    public var repost: String? {
        get {
            return repostInfoLabel.text
        }
        set {
            if let reply = newValue {
                repostInfoStackView.isHidden = false
                repostInfoLabel.text = reply
            } else {
                repostInfoStackView.isHidden = true
            }
        }
    }
    
    open override func reset() {
        updateAvatar(with: nil)
        avatarButton.removeTap()
        avatarButton.isEnabled = true
        avatarButton.isUserInteractionEnabled = true
        nameLabel.text = nil
        dateLabel.text = nil
        repostInfoLabel.text = nil
        repostInfoStackView.isHidden = true
        messageLabel.text = nil
        messageBottomConstraint.priority = .defaultHigh + 1
    }
    
    public func setActivity(with activity: Activity) {
        self.currentActivity = activity
        self.activityID = activity.id
    }
    
    public func updateAvatar(with image: UIImage?) {
        if let image = image {
            avatarButton.setImage(image, for: .normal)
            avatarButton.contentHorizontalAlignment = .fill
            avatarButton.contentVerticalAlignment = .fill
        } else {
            avatarButton.setImage(UIImage(named: "user_icon"), for: .normal)
            avatarButton.contentHorizontalAlignment = .center
            avatarButton.contentVerticalAlignment = .center
        }
        avatarButton.imageView?.contentMode = .scaleAspectFill
    }
    
    public func updateAvatar(with profilePictureURL: String) {
        guard let imageURL = URL(string: profilePictureURL) else { return }
        avatarButton.loadImage(from: imageURL.absoluteString, placeholder: UIImage(named: "user_icon")) { [weak self] _ in
            self?.updateAvatar(with: self?.avatarButton.imageView?.image)
        }
    }

    public func updatePhoto(with url: URL) {
        messageBottomConstraint.priority = .defaultLow
        photoImageView.isHidden = false
        postImageURL = url
        sendImageURLValues?(url)
        loadImage(with: url)
    }
    
    private func loadImage(with url: URL) {
        let imageId = url.getImageID()
        let resource = KF.ImageResource(downloadURL: url, cacheKey: imageId)
        
        photoImageView.loadImage(from: resource)
    }

    
    @IBAction func postSettings(_ sender: UIButton) {
       guard let currentActivity = currentActivity else { return }
       postSettingsTapped?(currentActivity)
    }
    
    @IBAction func photoImageTapped(_ sender: UIButton) {
        guard let postImageURL = postImageURL else { return }
        photoImageTapped?(postImageURL)
    }
    
    @IBAction func profileImageTapped(_ sender: UIButton) {
        navigateToUserProfileAction()
    }
    
    @IBAction func userNameTapped(_ sender: UIButton) {
        navigateToUserProfileAction()
    }
    
    private func navigateToUserProfileAction() {
        let originalActivity = currentActivity?.original
        guard let actorId = originalActivity?.actor.id else { return }
        
        profileImageTapped?(actorId)
    }
}

extension PostHeaderTableViewCell {
    
    public func update<T: ActivityProtocol>(with activity: T, originalActivity: T? = nil) where T.ActorType: UserNameRepresentable {
        let originalActivity = originalActivity ?? activity
        nameLabel.text = originalActivity.actor.name
        
        if let textRepresentable = originalActivity as? TextRepresentable {
            messageLabel.text = textRepresentable.text
        }
        
        if let object = originalActivity.object as? ActivityObject {
            switch object {
            case .text(let text):
                messageLabel.text = text
            case .image(let url):
                updatePhoto(with: url)
            case .following(let user):
                messageLabel.text = "Follow to \(user.name)"
            default:
                return
            }
        }
        
        dateLabel.text = activity.time?.relative
        
        if activity.verb == .repost {
            repost = "reposted by \(activity.actor.name)"
        }
    }
    
    public func updateAvatar<T: AvatarRepresentable>(with avatar: T, action: UIControl.Action? = nil) {
        if let action = action {
            avatarButton.addTap(action)
        } else {
            avatarButton.isUserInteractionEnabled = false
        }
        
        if let avatarURL = avatar.avatarURL {
            ImagePipeline.shared.loadImage(with: avatarURL.imageRequest(in: avatarButton), completion:  { [weak self] result in
                self?.updateAvatar(with: try? result.get().image)
            })
        }
    }
}
