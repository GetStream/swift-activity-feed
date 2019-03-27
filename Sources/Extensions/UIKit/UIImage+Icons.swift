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
    
    /// A home icon.
    public static let homeIcon = stream(named: "home_icon")
    /// An image icon.
    public static let imageIcon = stream(named: "image_icon")
    /// A close button icon.
    public static let closeIcon = stream(named: "close_icon")
    /// An user icon.
    public static let userIcon = stream(named: "user_icon")
    /// A bell icon.
    public static let bellIcon = stream(named: "notifications_icon")
    /// A reply icon.
    public static let replyIcon = stream(named: "reply_icon")
    /// An unselected like icon.
    public static let likeInactiveIcon = stream(named: "love_gray_icon")
    /// A selected like icon.
    public static let likeIcon = stream(named: "love_icon")
    /// A repost icon.
    public static let repostIcon = stream(named: "repost_icon")
    
    /// An image of an icon from Stream Activity Feed Components.
    public static func stream(named name: String) -> UIImage {
        let bundle = Bundle(for: FlatFeedPresenter<Activity>.self)
        return UIImage(named: name, in: bundle, compatibleWith: nil) ?? .init(color: .black)
    }
}
