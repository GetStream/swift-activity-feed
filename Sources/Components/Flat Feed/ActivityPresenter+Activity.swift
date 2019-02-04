//
//  ActivityPresenter+Activity.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 01/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import GetStream

extension ActivityPresenter where T == Activity {
    
    public var ogData: OGResponse? {
        return activity.originalActivity.attachment?.openGraphData
    }
    
    public var attachmentImageURLs: [URL]? {
        if let imageURLs = activity.attachment?.imageURLs, imageURLs.count > 0 {
            return imageURLs
        }
        
        return nil
    }
    
    public var cellsCount: Int {
        var count = 3
        
        if attachmentImageURLs != nil {
            count += 1
        }
        
        if ogData != nil {
            count += 1
        }
        
        return count
    }
}

// MARK: - Reactions

extension ActivityPresenter where T == Activity {
    var likedTitle: String? {
        guard let reactions = activity.originalActivity.latestReactions?[.like] else {
            return nil
        }
        
        let count = activity.originalActivity.likesCount
        
        if count > 2, let first = reactions.first {
            return "\(first.userId) and \(count) others liked your post"
        }
        
        return nil
    }
}
