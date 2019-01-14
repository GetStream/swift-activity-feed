//
//  User.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 14/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import GetStream

final class User: GetStream.User {
    private enum CodingKeys: String, CodingKey {
        case name
        case website
        case description
        case avatarURL
        case profileBackgroundURL
    }
    
    let name: String
    var website: URL?
    var description: String?
    var avatarURL: URL?
    var profileBackgroundURL: URL?
    
    init(name: String, id: String) {
        self.name = name
        super.init(id: id)
    }
    
    required init(from decoder: Decoder) throws {
        let dataContainer = try decoder.container(keyedBy: DataCodingKeys.self)
        let container = try dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        name = try container.decode(String.self, forKey: .name)
        website = try container.decodeIfPresent(URL.self, forKey: .website)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        avatarURL = try container.decodeIfPresent(URL.self, forKey: .avatarURL)
        profileBackgroundURL = try container.decodeIfPresent(URL.self, forKey: .profileBackgroundURL)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var dataContainer = encoder.container(keyedBy: DataCodingKeys.self)
        var container = dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        try container.encode(name, forKey: .name)
        try container.encode(website, forKey: .website)
        try container.encode(description, forKey: .description)
        try container.encode(avatarURL, forKey: .avatarURL)
        try container.encode(profileBackgroundURL, forKey: .profileBackgroundURL)
        try super.encode(to: encoder)
    }
}
