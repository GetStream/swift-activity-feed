//
//  TextRepresentable.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 12/03/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

/// A text container protocol.
public protocol TextRepresentable {
    // A text.
    var text: String? { get set }
}
