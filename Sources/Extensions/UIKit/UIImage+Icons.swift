//
//  UITabBarItem+Extensions.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 16/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    public static let homeIcon = stream(named: "home_icon")
    public static let profileIcon = stream(named: "user_icon")
    public static let imageIcon = stream(named: "image_icon")
    public static let closeIcon = stream(named: "close_icon")
    public static let userIcon = stream(named: "user_icon")
    public static let bellIcon = stream(named: "notifications_icon")
    public static let replyIcon = stream(named: "reply_icon")
    public static let likeInactiveIcon = stream(named: "love_gray_icon")
    public static let likeIcon = stream(named: "love_icon")
    public static let repostIcon = stream(named: "repost_icon")
    
    public static func stream(named name: String) -> UIImage {
        let bundle = Bundle(for: FlatFeedPresenter<Activity>.self)
        return UIImage(named: name, in: bundle, compatibleWith: nil) ?? .init(color: .black)
    }
}
