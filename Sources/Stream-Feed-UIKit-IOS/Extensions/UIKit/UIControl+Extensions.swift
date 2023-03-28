//
//  UIControl+Extensions.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 16/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

// MARK: - Action block for UIControl

extension UIControl {
    private struct AssociatedKeys {
        static var touchUpInsideKey: UInt8 = 0
        static var valueChangedKey: UInt8 = 0
    }
    
    /// An action block for the `UIControl`.
    public typealias Action = (_ control: UIControl) -> Void
    
    /// Add a tap action to the control.
    ///
    /// - Parameter action: an action block.
    public func addTap(_ action: @escaping UIControl.Action) {
        let sleeve = UIControlActionSleeve(self, action)
        objc_setAssociatedObject(self, &AssociatedKeys.touchUpInsideKey, sleeve, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        addTarget(sleeve, action: #selector(UIControlActionSleeve.invoke), for: .touchUpInside)
    }
    
    /// Remove a tap action block.
    public func removeTap() {
        if let sleeve = objc_getAssociatedObject(self, &AssociatedKeys.touchUpInsideKey) {
            removeTarget(sleeve, action: nil, for: .touchUpInside)
            objc_setAssociatedObject(self, &AssociatedKeys.touchUpInsideKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// Add a value changed action to the control.
    ///
    /// - Parameter action: an action block.
    public func addValueChangedAction(_ action: @escaping UIControl.Action) {
        let sleeve = UIControlActionSleeve(self, action)
        objc_setAssociatedObject(self, &AssociatedKeys.valueChangedKey, sleeve, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        addTarget(sleeve, action: #selector(UIControlActionSleeve.invoke), for: .valueChanged)
    }
    
    /// Remove a value changed action block.
    public func removeValueChangedAction() {
        if let sleeve = objc_getAssociatedObject(self, &AssociatedKeys.valueChangedKey) {
            removeTarget(sleeve, action: nil, for: .valueChanged)
            objc_setAssociatedObject(self, &AssociatedKeys.valueChangedKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

private final class UIControlActionSleeve {
    weak var control: UIControl?
    let action: UIControl.Action
    
    init (_ control: UIControl, _ action: @escaping UIControl.Action) {
        self.control =  control
        self.action = action
    }
    
    @objc func invoke () {
        if let control = control {
            action(control)
        }
    }
}
