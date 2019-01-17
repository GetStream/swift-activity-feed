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
        static let gray = UIColor(red: 0.21, green: 0.25, blue: 0.28, alpha: 1)
    }
    
    static func setup() {
        let appearance = UINavigationBar.appearance()
        appearance.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 13, weight: .medium), .kern: 1]
    }
}
