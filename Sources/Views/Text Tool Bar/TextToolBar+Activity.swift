//
//  TextToolBar+Activity.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 25/03/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import GetStream

extension TextToolBar {
    
    /// Add an Activity to the flat feed.
    public func addActivity(to flatFeed: FlatFeed, completion: @escaping ActivityCompletion<Activity>) {
        guard isValidContent else {
            print("❌ The TextToolBar content is not valid")
            completion(.failure(.unexpectedError(nil)))
            return
        }
        
        isEnabled = false
        activityIndicatorView.startAnimating()
        
        if images.isEmpty {
            addActivity(to: flatFeed, imageURLs: [], completion: completion)
        } else {
            uploadImages { [weak self] urls, _ in
                if let urls = urls {
                    self?.addActivity(to: flatFeed, imageURLs: urls, completion: completion)
                }
            }
        }
    }
    
    private func addActivity(to flatFeed: FlatFeed, imageURLs: [URL], completion: @escaping ActivityCompletion<Activity>) {
        guard let user = User.current else {
            print("❌ The current user not found")
            completion(.failure(.unexpectedError(nil)))
            return
        }
        
        let object: ActivityObject
        var imageURLs = imageURLs
        
        if !text.isEmpty {
            object = .text(text)
        } else if let url = imageURLs.first {
            object = .image(url)
            imageURLs.remove(at: 0)
        } else {
            completion(.failure(.unexpectedError(nil)))
            return
        }
        
        // Create a new post with entered text.
        let activity = Activity(actor: user, verb: .post, object: object)
        let attachment = ActivityAttachment.make()
        
        // Attach Open Graph data.
        if let openGraphData = openGraphData {
            attachment.openGraphData = openGraphData
            activity.attachment = attachment
        }
        
        // Attach images.
        if !imageURLs.isEmpty {
            attachment.imageURLs = imageURLs
            activity.attachment = attachment
        }
        
        reset()
        flatFeed.add(activity, completion: completion)
    }
}
