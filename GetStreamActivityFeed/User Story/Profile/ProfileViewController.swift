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
    
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
            
            if let container = avatarImageView.superview {
                container.layer.shadowOffset = CGSize(width: 0, height: 2)
                container.layer.shadowColor = UIColor(white: 0, alpha: 0.2).cgColor
                container.layer.shadowOpacity = 1
                container.layer.shadowRadius = 30
                container.layer.shadowPath = UIBezierPath(roundedRect: container.bounds,
                                                          cornerRadius: avatarImageView.layer.cornerRadius).cgPath
            }
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var feedTableView: UITableView!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        nameLabel.text = user?.name
    }
    
    private func loadAvatar() {
        guard let avatarURL = user?.avatarURL else {
            return
        }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: avatarURL) {
                let image = UIImage(data: data)
                
                DispatchQueue.main.async {
                    self.avatarImageView.image = image
                    self.backgroundImageView.image = image
                }
            }
        }
    }
}
