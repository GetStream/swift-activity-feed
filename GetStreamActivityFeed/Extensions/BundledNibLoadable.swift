//
//  BundledNibLoadable.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 14/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

/// This protocol provides factory methods for loading a UIViewController or UIView with associated Nib file.
protocol BundledNibLoadable {}

extension BundledNibLoadable where Self: UIViewController {
    
    /// Creates the view controller with associated nib file from the bundle
    /// in which this class is located at run-time.
    ///
    /// - Parameter named: the name of the associated nib file or if the class name matches the nib name, consider using nil.
    /// - Returns: the instantiated view controller with associated nib file
    static func fromBundledNib(named nibName: String? = String(describing: Self.self)) -> Self {
        return Self(nibName: nibName, bundle: Bundle(for: Self.self))
    }
}
