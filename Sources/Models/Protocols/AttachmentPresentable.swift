//
//  AttachmentPresentable.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 05/03/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import GetStream

public protocol AttachmentPresentable: ActivityProtocol {
    var attachment: ActivityAttachment? { get }
}
