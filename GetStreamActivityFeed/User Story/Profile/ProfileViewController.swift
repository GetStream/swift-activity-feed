//
//  ProfileViewController.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 15/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, BundledStoryboardLoadable {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "notification_icon"), tag: 4)
        nameLabel.text = user?.name
        loadAvatar()
    }
    
    private func loadAvatar() {
        guard let avatarURL = user?.avatarURL else {
            return
        }
        
        let avatarWidth = avatarView.bounds.width
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: avatarURL) {
                let image = UIImage(data: data)
                
                if let image = image {
                    let avatarImage = image.square(with: avatarWidth)
                    let tabBarImage = image.square(with: 25).rounded.transparent(alpha: 0.8).original
                    
                    DispatchQueue.main.async {
                        self.avatarView.image = avatarImage
                        self.backgroundImageView.image = image
                        self.tabBarItem = UITabBarItem(title: "Profile", image: tabBarImage, tag: 4)
                    }
                }
            }
        }
    }
}
