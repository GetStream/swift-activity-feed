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
    public typealias Action = (_ control: UIControl) -> Void
    
    /// Add an action to the control with a given action block.
    ///
    /// - Parameters:
    ///     - controlEvents: A bitmask specifying the control-specific events for which the action method is called.
    ///                      Always specify at least one constant. For a list of possible constants, see `UIControl.Event`.
    ///     - action: a block of an action.
    public func addAction(for controlEvents: UIControl.Event, _ action: @escaping UIControl.Action) {
        let sleeve = UIControlActionSleeve(self, action)
        addTarget(sleeve, action: #selector(UIControlActionSleeve.invoke), for: controlEvents)
        objc_setAssociatedObject(self, actionId(for: controlEvents), sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
    
    /// Remove an action block for the given controlEvents.
    ///
    /// - Parameter controlEvents: A bitmask specifying the control-specific events for which the action method is called.
    ///                            Always specify at least one constant. For a list of possible constants, see `UIControl.Event`.
    public func removeAction(for controlEvents: UIControl.Event) {
        let key = actionId(for: controlEvents)
        
        if let sleeve = objc_getAssociatedObject(self, key) {
            removeTarget(sleeve, action: nil, for: controlEvents)
            objc_setAssociatedObject(self, key, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private func actionId(for controlEvents: UIControl.Event) -> String {
        return String(ObjectIdentifier(self).hashValue) + String(controlEvents.rawValue)
    }
}

private final class UIControlActionSleeve {
    let control: UIControl
    let action: UIControl.Action
    
    init (_ control: UIControl, _ action: @escaping UIControl.Action) {
        self.control =  control
        self.action = action
    }
    
    @objc func invoke () {
        action(control)
    }
}

// MARK: - Button tap

extension UIButton {
    public func addTap(_ action: @escaping UIControl.Action) {
        addAction(for: .touchUpInside, action)
    }
    
    public func removeTap() {
        removeAction(for: .touchUpInside)
    }
}
