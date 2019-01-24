//
//  ActivityLikable.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 24/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import GetStream

/// A protocol define an Activity that can be liked.
public protocol ActivityLikable: ActivityRepostable {
    /// Check if the activity is liked.
    var isLiked: Bool { get }
    
    /// The liked reaction.
    var likedReaction: Reaction<ReactionNoExtraData>? { get }
    
    /// The number of likes.
    var likesCount: Int { get }
}
