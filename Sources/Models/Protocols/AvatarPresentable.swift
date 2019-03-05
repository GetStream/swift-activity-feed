//
//  AvatarPresentable.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 15/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import GetStream

public protocol AvatarPresentable: UserProtocol {
    var avatarURL: URL? { get }
}
