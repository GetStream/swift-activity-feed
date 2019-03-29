//
//  UserNamePresentable.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 05/03/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import GetStream

/// An user name container protocol.
public protocol UserNameRepresentable {
    /// A name of the user.
    var name: String { get }
}
