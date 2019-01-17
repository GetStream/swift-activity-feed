//
//  User.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 14/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import GetStream

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

// MARK: - Avatar

extension User {
    public func loadAvatar(completion: @escaping (_ image: UIImage?) -> Void) {
        guard let avatarURL = avatarURL else {
            completion(nil)
            return
        }
        
        dispatchQueue.async { [weak self] in
            if let image = self?.avatarImage {
                DispatchQueue.main.async { completion(image) }
                return
            }
            
            if let data = try? Data(contentsOf: avatarURL) {
                if let image = UIImage(data: data) {
                    self?.avatarImage = image
                    DispatchQueue.main.async { completion(image) }
                } else {
                    self?.avatarURL = nil
                    self?.avatarImage = nil
                    DispatchQueue.main.async { completion(nil) }
                }
            }
        }
    }
    
    public func updateAvatarURL(image: UIImage, completion: @escaping (_ error: Error?) -> Void) {
        guard let file = File(name: name, jpegImage: image) else {
            completion(nil)
            return
        }
        
        UIApplication.shared.appDelegate.client?.upload(image: file) { [weak self] result in
            DispatchQueue.main.async {
                do {
                    self?.avatarURL = try result.get()
                    self?.avatarImage = image
                    completion(nil)
                } catch {
                    print("❌", #function, error.localizedDescription)
                    completion(error)
                }
            }
        }
    }
}
