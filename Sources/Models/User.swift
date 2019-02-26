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

public final class User: GetStream.User, AvatarPresentable {
    private enum CodingKeys: String, CodingKey {
        case name
        case avatarURL = "profileImage"
    }
    
    public var name: String
    public var avatarURL: URL? {
        didSet {
            avatarImage = nil
        }
    }
    
    private let dispatchQueue = DispatchQueue(label: "io.getstream.User")
    private var avatarImage: UIImage?
    
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
    public func refresh(completion: @escaping (_ user: User?) -> Void) {
        Client.shared.get(typeOf: User.self, userId: id, withFollowCounts: true) { result in
            completion(try? result.get())
        }
    }
}

// MARK: - Following

extension User {
    public func isFollow(toTarget target: FeedId,
                         completion: @escaping (_ isFollow: Bool, _ following: Follower?, _ error: Error?) -> Void) {
        guard let userFeed = UIApplication.shared.appDelegate.userFeed else {
            print("⚠️", #function, "UserFeed is nil")
            completion(false, nil, nil)
            return
        }
        
        userFeed.following(filter: [target]) {
            if let response = try? $0.get() {
                completion(response.results.first != nil, response.results.first, nil)
            } else {
                completion(false, nil, $0.error)
            }
        }
    }
}

// MARK: - Avatar

extension User {
    public func loadAvatar(completion: @escaping (_ image: UIImage?) -> Void) {
        guard let avatarURL = avatarURL else {
            completion(nil)
            return
        }
        
        if let image = avatarImage {
            completion(image)
            return
        }
        
        ImagePipeline.shared.loadImage(with: avatarURL) { [weak self] response, error in
            guard let self = self else {
                return
            }
            
            if let response = response {
                self.avatarImage = response.image
                completion(response.image)
            } else {
                self.avatarURL = nil
                self.avatarImage = nil
                completion(nil)
            }
        }
    }
    
    public func updateAvatarURL(image: UIImage, completion: @escaping (_ error: Error?) -> Void) {
        guard let file = File(name: name, jpegImage: image) else {
            completion(nil)
            return
        }
        
        Client.shared.upload(image: file) { [weak self] result in
            guard let self = self else {
                return
            }
            
            do {
                self.avatarURL = try result.get()
                self.avatarImage = image
                completion(nil)
            } catch {
                print("❌", #function, error.localizedDescription)
                completion(error)
            }
        }
    }
}
