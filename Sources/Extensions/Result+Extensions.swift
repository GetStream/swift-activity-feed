//
//  Result+Extensions.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 10/09/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

extension Result {
    /// Get the error from the result if it failed.
    public var error: Error? {
        if case .failure(let error) = self {
            return error
        }
        
        return nil
    }
}
