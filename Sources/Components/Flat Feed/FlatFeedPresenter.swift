//
//  FlatFeedPresenter.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 17/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import GetStream
import Result

public final class FlatFeedPresenter<T: ActivityProtocol>: PaginatorProtocol {
    public typealias Completion = (_ error: Error?) -> Void
    
    public let flatFeed: FlatFeed
    public let reactionPresenter: ReactionPresenter
    public var includeReactions: FeedReactionsOptions = [.counts, .own, .latest]
    
    public private(set) var items: [ActivityPresenter<T>] = []
    public var next: Pagination = .none
    public let subscriptionPresenter: SubscriptionPresenter<T>
    public var reactionTypes: ActivityPresenterReactionTypes = []
    
    public init(flatFeed: FlatFeed, reactionTypes: ActivityPresenterReactionTypes = []) {
        self.flatFeed = flatFeed
        self.reactionTypes = reactionTypes
        flatFeed.callbackQueue = DispatchQueue.init(label: "io.getstream.FlatFeedPresenter", qos: .userInitiated)
        reactionPresenter = ReactionPresenter()
        subscriptionPresenter = SubscriptionPresenter(feed: flatFeed)
    }
    
    public func load(_ pagination: Pagination = .none, completion: @escaping Completion) {
        flatFeed.get(typeOf: T.self, pagination: pagination, includeReactions: includeReactions) { [weak self] result in
            guard let self = self else {
                return
            }
            
            if case .none = pagination {
                self.items = []
                self.next = .none
            }
            
            var error: Error?
            
            do {
                let response = try result.get()
                
                self.items.append(contentsOf: response.results
                    .map({ ActivityPresenter(activity: $0,
                                             reactionPresenter: self.reactionPresenter,
                                             reactionTypes: self.reactionTypes) }))
                
                self.next = response.next ?? .none
            } catch let responseError {
                error = responseError
            }
            
            DispatchQueue.main.async { completion(error) }
        }
    }
}

// MARK: - Activities

extension FlatFeedPresenter {
    public func remove(activity: Activity, _ completion: @escaping Completion) {
        flatFeed.remove(activityId: activity.id) { result in
            completion(result.error)
        }
    }
}

// MARK: - Following

extension FlatFeedPresenter {
    
    public func follow(toTarget target: FeedId, activityCopyLimit: Int = 10, _ completion: @escaping Completion) {
        flatFeed.follow(toTarget: target, activityCopyLimit: activityCopyLimit) { completion($0.error) }
    }
    
    public func unfollow(fromTarget target: FeedId, keepHistory: Bool = false, _ completion: @escaping Completion) {
        flatFeed.unfollow(fromTarget: target, keepHistory: keepHistory) { completion($0.error) }
    }
}
