//
//  Range+Extensions.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 25/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

extension NSRange {
    /// Create a NSRange from Swift Range.
    public init(_ range: Range<String.Index>) {
        self.init(location: range.lowerBound.encodedOffset,
                  length: range.upperBound.encodedOffset - range.lowerBound.encodedOffset)
    }
}

extension Range where Bound == String.Index {
    
    /// Get the NSRange from the Swift Range.
    public var range: NSRange {
        return NSRange(self)
    }
}
