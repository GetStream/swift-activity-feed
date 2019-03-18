//
//  AvatarPresentable.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 15/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import GetStream
import Nuke

public protocol AvatarRepresentable: class, UserProtocol {
    var avatarURL: URL? { get set }
    var avatarImage: UIImage? { get set }
    
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
        
        ImagePipeline.shared.loadImage(with: avatarURL) { [weak self] response, error in
            guard let self = self else {
                completion(nil)
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
