//
//  Result+Extensions.swift
//  GetStreamActivityFeed
//
//  Created by Matheus Cardoso on 5/13/20.
//  Copyright © 2020 Stream.io Inc. All rights reserved.
//

import Foundation

extension Result {
    var error: Failure? {
        switch self {
        case .failure(let error):
            return error
        default:
            return nil
        }
    }
}
