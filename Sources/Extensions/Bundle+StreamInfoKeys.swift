//
//  Bundle+StreamInfoKeys.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 14/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import GetStream

extension Bundle {
    public static let streamAPIKey = "Stream API Key"
    public static let streamAppId = "Stream App Id"
    public static let streamToken = "Stream Token"
    
    public func setupStreamClient() {
        guard let apiKey = streamValue(for: Bundle.streamAPIKey),
            let appId = streamValue(for: Bundle.streamAppId),
            let token = streamValue(for: Bundle.streamToken) else {
                print("⚠️ Stream bundle keys not found")
                return
        }
        
        Client.config = .init(apiKey: apiKey, appId: appId, token: token)
    }
    
    private func streamValue(for key: String) -> String? {
        if let value = infoDictionary?[key] as? String, !value.isEmpty {
            return value
        }
        
        return nil
    }
}
