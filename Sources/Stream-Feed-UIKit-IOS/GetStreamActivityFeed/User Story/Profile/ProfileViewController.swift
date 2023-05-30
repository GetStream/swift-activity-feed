//
//  ProfileViewController.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 15/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import SnapKit
import GetStream

class ProfileViewController: UIViewController, BundledStoryboardLoadable {
    
    static var storyboardName = "Profile"
    
    @IBOutlet weak var backgroundImageView: UIImageView! {
        didSet {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.cgColor]
            backgroundImageView.layer.addSublayer(gradientLayer)
            gradientLayer.frame = backgroundImageView.bounds
        }
    }
    
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var feedContainerView: UIView!
    
    var builder: ProfileBuilder?
    
    var user: User? {
        didSet {
            if let user = user, let currentUser = Client.shared.currentUser {
                isCurrentUser = user.id == currentUser.id
            }
        }
    }
    
    private(set) var isCurrentUser: Bool = false
    private var flatFeedViewController: ActivityFeedViewController?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        loadAvatar(onlyTabBarItem: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTabBarItem()
        DispatchQueue.main.async { self.loadAvatar(onlyTabBarItem: true) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideBackButtonTitle()
        setupTabBarItem()
        updateUser()
        setupFlatFeed()

        if isCurrentUser {
            addEditButton()
        } else {
            addFollowButton()
            refreshUser()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.presentTransparentNavigationBar(animated: false)
        flatFeedViewController?.reloadData()
    }
    
    private func setupFlatFeed() {
        guard let userId = user?.id else {
            return
        }
        
        let feedId = FeedId.user(with: userId)
        flatFeedViewController = builder?.activityFeedBuilder?.activityFeedViewController(feedId: feedId)
        
        guard let flatFeedViewController = flatFeedViewController else {
            return
        }
        
        add(viewController: flatFeedViewController, to: feedContainerView)
        headerView.removeFromSuperview()
        flatFeedViewController.tableView.tableHeaderView = headerView
        
        let navigationBarHeight = UIApplication.shared.statusBarFrame.height
            + (navigationController?.navigationBar.frame.height ?? 0)
        
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-navigationBarHeight)
            make.left.right.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        headerViewHeightConstraint.constant -= navigationBarHeight
        
        guard isCurrentUser else {
            return
        }
        
        flatFeedViewController.removeActivityAction = { [weak self, weak flatFeedViewController] activity in
            guard let self = self else {
                return
            }
            
            guard activity.original.isUserReposted else {
                flatFeedViewController?.presenter?.remove(activity: activity, self.refresh)
                return
            }
            
            if let repostReaction = activity.original.userRepostReaction {
                flatFeedViewController?.presenter?.reactionPresenter
                    .remove(reaction: repostReaction, activity: activity) { [weak self] in self?.refresh($0.error) }
            }
        }
    }
    
    private func refresh(_ error: Error?) {
        if let error = error {
            showErrorAlert(error)
        } else {
            flatFeedViewController?.reloadData()
        }
    }
    
    private func setupTabBarItem(image: UIImage? = UIImage(named: "user_icon")) {
        tabBarItem = UITabBarItem(title: "Profile", image: image, tag: 4)
    }
    
    func updateUser() {
        nameLabel.text = user?.name
        followersLabel.text = String(user?.followersCount ?? 0)
        followingLabel.text = String(user?.followingCount ?? 0)
        loadAvatar()
    }
    
    func refreshUser() {
        user?.refresh(completion: { [weak self] user in
            if let user = user {
                self?.user = user
                self?.updateUser()
            }
        })
    }
}

// MARK: - Navigation Bar

extension ProfileViewController {
    private func addEditButton() {
        guard let builder = builder else {
            return
        }
        
        let button = BarButton(title: "Edit Profile", backgroundColor: Appearance.Color.transparentWhite)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        
        button.addTap { [weak self] _ in
            let viewController = builder.editProfileNavigationController { $0.completion = self?.updateEditedUser }
            self?.present(viewController, animated: true)
        }
    }
    
    private func updateEditedUser(_ user: User) {
        avatarView.image = nil
        backgroundImageView.image = nil
        self.user = user
        updateUser()
    }
    
    private func addFollowButton() {
        guard let flatFeedPresenter = flatFeedViewController?.presenter else {
            return
        }
        
        let button =  BarButton(title: "Follow", backgroundColor: Appearance.Color.blue)
        button.setTitle("Updating...", backgroundColor: Appearance.Color.transparentWhite, for: .disabled)
        button.setTitle("Following", backgroundColor: Appearance.Color.transparentWhite, for: .selected)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        
        button.addTap { [weak flatFeedPresenter]  in
            if let button = $0 as? BarButton,
                let feedId = flatFeedPresenter?.flatFeed.feedId,
                let userFeed = User.current?.feed {
                let isFollowing = button.isSelected
                button.isEnabled = false
                
                if isFollowing {
                    userFeed.unfollow(fromTarget: feedId) {
                        button.isEnabled = true
                        button.isSelected = !($0.error == nil)
                    }
                } else {
                    userFeed.follow(toTarget: feedId) {
                        button.isEnabled = true
                        button.isSelected = $0.error == nil
                    }
                }
            }
        }
        
        // Update the current state.
        button.isEnabled = false
        
        User.current?.isFollow(toTarget: flatFeedPresenter.flatFeed.feedId) { [weak self] in
            button.isEnabled = true
            
            if let error = $2 {
                self?.showErrorAlert(error)
            } else {
                button.isSelected = $0
            }
        }
    }
}

// MARK: - Avatar

extension ProfileViewController {
    
    private func loadAvatar(onlyTabBarItem: Bool = false) {
        user?.loadAvatar { [weak self] image in
            guard let self = self else {
                return
            }
            
            if let image = image {
                let avatarWidth = onlyTabBarItem ? 0 : self.avatarView.bounds.width
                
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.updateAvatar(image: image, avatarWidth: avatarWidth, onlyTabBarItem: onlyTabBarItem)
                }
                
            } else if !onlyTabBarItem {
                self.avatarView.image = nil
                self.backgroundImageView.image = nil
                self.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "user_icon"), tag: 4)
            }
        }
    }
    
    private func updateAvatar(image: UIImage, avatarWidth: CGFloat, onlyTabBarItem: Bool) {
        let avatarImage = image.square(with: avatarWidth)
        let tabBarImage = image.square(with: 25).rounded.transparent(alpha: 0.8).original
        
        DispatchQueue.main.async {
            self.tabBarItem = UITabBarItem(title: "Profile", image: tabBarImage, tag: 4)

            if !onlyTabBarItem {
                self.avatarView.image = avatarImage
                self.backgroundImageView.image = image
            }
        }
    }
}
