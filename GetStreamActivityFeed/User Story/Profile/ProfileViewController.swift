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
    
    var user: User?
    var isCurrentUser: Bool = false
    var builder: ProfileBuilder?
    private var flatFeedViewController: FlatFeedViewController?
    
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
        
        if isCurrentUser {
            addEditButton()
        } else {
            addFollowButton()
            refreshUser()
        }
        
        setupFlatFeed()
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
        
        let feedId = FeedId(feedSlug: "user", userId: userId)
        flatFeedViewController = builder?.activityFeedBuilder?.flatFeedViewController(feedId: feedId)
        
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
            
            guard activity.originalActivity.isReposted else {
                flatFeedViewController?.presenter?.remove(activity: activity, self.refresh)
                return
            }
            
            if let repostReaction = activity.repostReaction {
                flatFeedViewController?.presenter?.remove(reaction: repostReaction, for: activity.originalActivity, self.refresh)
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
    
    private func setupTabBarItem(image: UIImage? = .profileIcon) {
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
        
        let button =  BarButton(title: "Edit Profile", backgroundColor: UIColor(white: 1, alpha: 0.7))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        
        button.addTap { _ in
            let viewController = builder.editProfileNavigationController { editProfileViewController in
                editProfileViewController.completion = { user in
                    self.user = user
                    self.updateUser()
                }
            }
            
            self.present(viewController, animated: true)
        }
    }
    
    private func addFollowButton() {
        let button =  BarButton(title: "Follow", backgroundColor: UIColor(red:0, green:0.48, blue:1, alpha:1))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
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
                self.tabBarItem = UITabBarItem(title: "Profile", image: .profileIcon, tag: 4)
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
