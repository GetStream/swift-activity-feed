//
//  ActivityRepostable.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 24/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import GetStream

/// A protocol define an Activity that can be reposted.
public protocol ActivityRepostable: ActivityProtocol where ReactionType == Reaction {
    
    /// The original Activity that was reposted.
    var originalActivity: Self { get }
    
    /// Check if the activity is reposted.
    var isReposted: Bool { get }
    
    /// The reposted reaction.
    var repostReaction: Reaction? { get }
    
    /// The number of reposts.
    var repostsCount: Int { get }
}
