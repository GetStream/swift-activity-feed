//
//  Appearance.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 17/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

struct Appearance {
    
    struct Color {
        static let red = UIColor(red: 1, green: 0.27, blue: 0.227, alpha: 1)
        static let blue = UIColor(red: 0, green: 0.478, blue: 1, alpha: 1)
        static let gray = UIColor(red: 0.21, green: 0.25, blue: 0.28, alpha: 1)
        static let lightGray = UIColor(white: 0.95, alpha: 1)
        static let transparentWhite = UIColor(white: 1, alpha: 0.7)
        static let transparentBlue = blue.withAlphaComponent(0.7)
        static let transparentBlue2 = blue.withAlphaComponent(0.15)
    }
    
    static func setup() {
        let appearance = UINavigationBar.appearance()
        appearance.titleTextAttributes = headerTextAttributes()
    }
    
    static func headerTextAttributes() -> [NSAttributedString.Key : Any]? {
        return [.font: UIFont(name: "GTWalsheimProMedium", size: 13.0)!, .kern: 1]
    }
}
