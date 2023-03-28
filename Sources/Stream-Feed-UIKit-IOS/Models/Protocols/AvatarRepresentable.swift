//
//  AvatarPresentable.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 15/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import GetStream
import Nuke
import UIKit

/// An avatar container protocol.
public protocol AvatarRepresentable: class, UserProtocol {
    /// An avatar URL.
    var avatarURL: URL? { get set }
    /// An avatar downloaded image.
    var avatarImage: UIImage? { get set }
    
    /// Loads avatar by the avatar URL.
    func loadAvatar(completion: @escaping (_ image: UIImage?) -> Void)
}

extension AvatarRepresentable {
    public func loadAvatar(completion: @escaping (_ image: UIImage?) -> Void) {
        guard let avatarURL = avatarURL else {
            completion(nil)
            return
        }
        
        if let image = avatarImage {
            completion(image)
            return
        }
        
        ImagePipeline.shared.loadImage(with: avatarURL) { [weak self] result in
            guard let self = self else {
                completion(nil)
                return
            }
            
            if let response = try? result.get() {
                self.avatarImage = response.image
                completion(response.image)
            } else {
                self.avatarURL = nil
                self.avatarImage = nil
                completion(nil)
            }
        }
    }
    
    /// Upload a new avatar image.
    public func updateAvatarURL(image: UIImage, name: String = "avatar", completion: @escaping (_ error: Error?) -> Void) {
        guard let file = File(name: name, jpegImage: image) else {
            completion(nil)
            return
        }
        
        Client.shared.upload(image: file) { [weak self] result in
            guard let self = self else {
                completion(nil)
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
