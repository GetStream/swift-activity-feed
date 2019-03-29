//
//  User.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 14/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import GetStream
import Nuke

/// An advanced Stream user with a name and avatar.
public final class User: GetStream.User, UserNameRepresentable, AvatarRepresentable {
    private enum CodingKeys: String, CodingKey {
        case name
        case avatarURL = "profileImage"
    }
    
    public var name: String
    
    public var avatarURL: URL? {
        didSet { avatarImage = nil }
    }
    
    private let dispatchQueue = DispatchQueue(label: "io.getstream.User")
    public var avatarImage: UIImage?
    
    init(name: String, id: String) {
        self.name = name
        super.init(id: id)
    }
    
    required init(from decoder: Decoder) throws {
        let dataContainer = try decoder.container(keyedBy: DataCodingKeys.self)
        let container = try dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        let name = try container.decodeIfPresent(String.self, forKey: .name)
        self.name = name ?? "NoName"
        avatarURL = try container.decodeIfPresent(URL.self, forKey: .avatarURL)
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var dataContainer = encoder.container(keyedBy: DataCodingKeys.self)
        var container = dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        try container.encode(name, forKey: .name)
        try container.encode(avatarURL, forKey: .avatarURL)
        try super.encode(to: encoder)
    }
}

// MARK: - Refresh

extension User {
    /// Reloads the user data and returns in a completion block.
    public func refresh(completion: @escaping (_ user: User?) -> Void) {
        Client.shared.get(typeOf: User.self, userId: id, withFollowCounts: true) { result in
            completion(try? result.get())
        }
    }
}

// MARK: - Following

extension User {
    /// Checks if the user feed is following to a target.
    public func isFollow(toTarget target: FeedId,
                         completion: @escaping (_ isFollow: Bool, _ following: Follower?, _ error: Error?) -> Void) {
        guard let userFeedId = FeedId.user else {
            print("⚠️", #function, "userId not found in the Token")
            completion(false, nil, nil)
            return
        }
        
        Client.shared.flatFeed(userFeedId).following(filter: [target]) {
            if let response = try? $0.get() {
                completion(response.results.first != nil, response.results.first, nil)
            } else {
                completion(false, nil, $0.error)
            }
        }
    }
}
