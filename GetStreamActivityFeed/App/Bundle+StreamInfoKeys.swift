//
//  Bundle+StreamInfoKeys.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 14/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

extension Bundle {
    
    var streamAPIKey: String? {
        return infoDictionary?["Stream API Key"] as? String
    }
    
    var streamAppId: String? {
        return infoDictionary?["Stream App Id"] as? String
    }
    
    var streamToken: String? {
        return infoDictionary?["Stream Token"] as? String
    }
}
