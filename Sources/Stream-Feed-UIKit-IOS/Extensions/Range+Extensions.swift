//
//  Range+Extensions.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 25/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

extension StringProtocol where Index == String.Index {
    
    /// Create a NSRange from a Range.
    ///
    /// - Parameter range: a Range.
    /// - Returns: a NSRange.
    public func nsRange(from range: Range<Index>) -> NSRange {
        return NSRange(range, in: self)
    }
}
