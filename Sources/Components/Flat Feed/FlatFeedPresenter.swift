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

final class FlatFeedPresenter<T: ActivityProtocol>: PaginatorProtocol {
    public typealias Completion = (_ error: Error?) -> Void
    
    let flatFeed: FlatFeed
    let reactionPresenter: ReactionPresenter
    var includeReactions: FeedReactionsOptions = [.counts, .own, .latest]
    
    public private(set) var items: [ActivityPresenter<T>] = []
    public var next: Pagination = .none
    
    init(flatFeed: FlatFeed) {
        self.flatFeed = flatFeed
        flatFeed.callbackQueue = DispatchQueue.init(label: "io.getstream.FlatFeedPresenter", qos: .userInitiated)
        reactionPresenter = ReactionPresenter(client: flatFeed.client)
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
                    .map({ ActivityPresenter(activity: $0, reactionPresenter: self.reactionPresenter) }))
                
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
    func remove(activity: Activity, _ completion: @escaping Completion) {
        flatFeed.remove(activityId: activity.id) { result in
            completion(result.error)
        }
    }
}

// MARK: - Following

extension FlatFeedPresenter {
    
    func follow(toTarget target: FeedId, activityCopyLimit: Int = 10, _ completion: @escaping Completion) {
        flatFeed.follow(toTarget: target, activityCopyLimit: activityCopyLimit) { completion($0.error) }
    }
    
    func unfollow(fromTarget target: FeedId, keepHistory: Bool = false, _ completion: @escaping Completion) {
        flatFeed.unfollow(fromTarget: target, keepHistory: keepHistory) { completion($0.error) }
    }
}
