//
//  ProfileViewController.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 15/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

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
    @IBOutlet weak var feedTableView: UITableView!
    
    var user: User?
    var isCurrentUser: Bool = false
    let builder = ProfileBuilder()
    
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
        setupTabBarItem()
        updateUser()
        
        if isCurrentUser {
            addEditButton()
        } else {
            addFollowButton()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.presentTransparentNavigationBar(animated: false)
        hideBackButtonTitle()
    }
    
    private func setupTabBarItem(image: UIImage? = .profileIcon) {
        tabBarItem = UITabBarItem(title: "Profile", image: image, tag: 4)
    }
    
    func updateUser() {
        nameLabel.text = user?.name
        loadAvatar()
    }
}

// MARK: - Navigation Bar

extension ProfileViewController {
    private func addEditButton() {
        let button =  BarButton(title: "Edit Profile", backgroundColor: UIColor(white: 1, alpha: 0.7))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        
        button.addTap { _ in
            let viewController = self.builder.editProfileViewController { editProfileViewController in
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
                
                DispatchQueue.global().async { [weak self] in
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
