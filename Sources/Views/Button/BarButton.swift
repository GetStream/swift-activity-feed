//
//  BarButton.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 16/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import SnapKit

public class BarButton: UIButton {
    
    /// Create a rounded button with a given title and background image.
    public convenience init(title: String,
                            backgroundColor: UIColor,
                            font: UIFont = .systemFont(ofSize: 12, weight: .medium),
                            cornerRadius: CGFloat = 6) {
        self.init(type: .custom)
        setTitle(title, backgroundColor: backgroundColor, for: .normal)
        titleLabel?.font = font
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    }
    
    public override var isEnabled: Bool {
        didSet { sizeToFit() }
    }
    
    public override var isSelected: Bool {
        didSet { sizeToFit() }
    }
}
