//
//  Range+Extensions.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 25/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

extension NSRange {
    public init(_ range: Range<String.Index>) {
        self.init(location: range.lowerBound.encodedOffset,
                  length: range.upperBound.encodedOffset - range.lowerBound.encodedOffset)
    }
}

extension Range where Bound == String.Index {
    var range: NSRange {
        return NSRange(self)
    }
}
