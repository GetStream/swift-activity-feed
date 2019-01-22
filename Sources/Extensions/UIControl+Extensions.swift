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
    private struct AssociatedKey {
        static var touchUpInside: UInt8 = 0
        static var valueChanged: UInt8 = 0
    }
    
    public typealias Action = (_ control: UIControl) -> Void
    
    /// Add a tap action to the control.
    ///
    /// - Parameter action: an action block.
    public func addTap(_ action: @escaping UIControl.Action) {
        let sleeve = UIControlActionSleeve(self, action)
        objc_setAssociatedObject(self, &AssociatedKey.touchUpInside, sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        addTarget(sleeve, action: #selector(UIControlActionSleeve.invoke), for: .touchUpInside)
    }
    
    /// Remove a tap action block.
    public func removeTap() {
        if let sleeve = objc_getAssociatedObject(self, &AssociatedKey.touchUpInside) {
            removeTarget(sleeve, action: nil, for: .touchUpInside)
            objc_setAssociatedObject(self, &AssociatedKey.touchUpInside, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// Add a value changed action to the control.
    ///
    /// - Parameter action: an action block.
    public func addValueChangedAction(_ action: @escaping UIControl.Action) {
        let sleeve = UIControlActionSleeve(self, action)
        objc_setAssociatedObject(self, &AssociatedKey.valueChanged, sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        addTarget(sleeve, action: #selector(UIControlActionSleeve.invoke), for: .valueChanged)
    }
    
    /// Remove a value changed action block.
    public func removeValueChangedAction() {
        if let sleeve = objc_getAssociatedObject(self, &AssociatedKey.valueChanged) {
            removeTarget(sleeve, action: nil, for: .valueChanged)
            objc_setAssociatedObject(self, &AssociatedKey.valueChanged, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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
