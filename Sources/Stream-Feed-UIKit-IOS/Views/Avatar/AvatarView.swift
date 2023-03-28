//
//  AvatarView.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 15/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

@IBDesignable
public class AvatarView: UIView {
    
    /// A corner radius.
    @IBInspectable
    public var cornerRadius: CGFloat {
        get {
            return imageView.layer.cornerRadius
        }
        set {
            imageView.layer.masksToBounds = newValue > 0
            imageView.layer.cornerRadius = newValue
            shadowPathNeedsToUpdate = true
        }
    }
    
    /// A shadow radius.
    @IBInspectable
    public var shadowRadius: CGFloat {
        get {
            return layer.shadowOpacity == 1 ? layer.shadowRadius : 0
        }
        set {
            layer.shadowOpacity = newValue > 0 ? 1 : 0
            layer.shadowRadius = newValue
            layer.shadowColor = UIColor(white: 0, alpha: 0.2).cgColor
            layer.shadowOffset = .zero
        }
    }
    
    /// An avatar image placeholder.
    @IBInspectable
    public var placeholder: UIImage? {
        didSet { touchPlaceholder() }
    }
    
    /// A default image background color.
    @IBInspectable
    public var defaultColor: UIColor?
    
    /// An image.
    public var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.contentMode = .scaleAspectFill
            imageView.image = newValue
            touchPlaceholder()
        }
    }
    
    /// Check if the image of the avatar is the placeholder image.
    public var isPlaceholder: Bool {
        if let currentImage = imageView.image, let currentPlaceholder = placeholder {
            return currentImage === currentPlaceholder
        }
        
        return true
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        
        return imageView
    }()
    
    private var shadowPathNeedsToUpdate: Bool = true
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        
        if shadowRadius > 0 {
            if cornerRadius > 0 {
                if layer.shadowPath == nil || shadowPathNeedsToUpdate {
                    layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
                }
            } else {
                layer.shadowPath = nil
            }
            
            imageView.backgroundColor = defaultColor ?? .white
            backgroundColor = .clear
        } else {
            imageView.backgroundColor = defaultColor ?? UIColor(white: 0.9, alpha: 0.5)
        }
    }
    
    private func touchPlaceholder() {
        if imageView.image == nil {
            imageView.contentMode = .center
            imageView.image = placeholder
        }
    }
}
