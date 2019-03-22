//
//  UIColor+Extensions.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 17/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit.UIColor

extension UIColor {
    /// Check the color is it's dark. This is useful when you need to choose
    /// the black or white text color for some background color.
    /// - Note: `let textColor: UIColor = backgroundColor.isDark ? .white : .black`
    ///
    /// - Returns: true if the color is dark.
    public var isDark: Bool {
        var white: CGFloat = 0
        getWhite(&white, alpha: nil)
        return white < 0.5
    }
}

// MARK: - UIImage with color

extension UIColor {
    /// Create an image 1x1 with the color.
    public var image: UIImage {
        return UIImage(color: self)
    }
}

// MARK: - Debug

extension UIColor {
    /// Create a random transparent color.
    static var debug: UIColor {
        return UIColor(hue: CGFloat.random(in: 0...10) / 10, saturation: 1, brightness: 1, alpha: 0.2)
    }
}
