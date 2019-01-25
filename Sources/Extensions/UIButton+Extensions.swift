//
//  UIButton+Extensions.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 25/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

extension UIButton {
    public func setTitle(_ title: String, backgroundColor: UIColor, for state: UIControl.State) {
        setTitle(title, for: state)
        setBackgroundImage(backgroundColor.image, for: state)
        setTitleColor(backgroundColor.isDark ? .white : Appearance.Color.gray, for: state)
    }
}
