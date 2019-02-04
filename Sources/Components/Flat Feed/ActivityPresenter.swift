//
//  ActivityPresenter.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 01/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import GetStream

public struct ActivityPresenter<T: ActivityProtocol> {
    public let activity: T
    public let reactionPresenter: ReactionPresenter
}
