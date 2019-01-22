//
//  FlatFeedPresenter.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 17/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import GetStream

public final class FlatFeedPresenter<T: ActivityProtocol> {
    public typealias Completion = (_ error: Error?) -> Void
    
    let flatFeed: FlatFeed
    var includeReactions: FeedReactionsOptions = [.counts, .own]
    
    private(set) var activities: [T] = []
    private var next: Pagination = .none
    
    init(flatFeed: FlatFeed) {
        self.flatFeed = flatFeed
        flatFeed.callbackQueue = DispatchQueue.init(label: "io.getstream.FlatFeedPresenter", qos: .userInitiated)
    }
    
    public func loadActivities(pagination: Pagination = .none, completion: @escaping Completion) {
        flatFeed.get(typeOf: T.self, pagination: pagination, includeReactions: includeReactions) { [weak self] result in
            guard let self = self else {
                return
            }
            
            if case .none = pagination {
                self.activities = []
                self.next = .none
            }
            
            var error: Error?
            
            do {
                let response = try result.get()
                self.activities.append(contentsOf: response.results)
                self.next = response.next ?? .none
            } catch let responseError {
                error = responseError
            }
            
            DispatchQueue.main.async { completion(error) }
        }
    }
    
    public func loadNext(completion: @escaping Completion) {
        loadActivities(pagination: next, completion: completion)
    }
}

// MARK: - Repost

extension FlatFeedPresenter {
    public func repost(_ activity: Activity, completion: @escaping Completion) {
        guard let userFeedId = UIApplication.shared.appDelegate.userFeed?.feedId else {
            return
        }
        
        var activity = activity
        
        // We can repost only the original activity.
        if case .repost(let originalActivity) = activity.object {
            activity = originalActivity
        }
        
        flatFeed.client.add(reactionTo: activity.id, kindOf: .repost, targetsFeedIds: [userFeedId]) { result in
            if let reaction = try? result.get() {
                var activity = activity
                activity.addOwnReaction(reaction)
            }
            
            completion(result.error)
        }
    }
}

// MARK: - Like

extension FlatFeedPresenter {
    public func like(_ activity: T, completion: @escaping Completion) {
        flatFeed.client.add(reactionTo: activity.id, kindOf: .like) { result in
            if let reaction = try? result.get() {
                var activity = activity
                activity.addOwnReaction(reaction)
            }
            
            completion(result.error)
        }
    }
}

// MARK: - Reactions

extension FlatFeedPresenter {
    func remove(reaction: Reaction<ReactionNoExtraData>, for activity: T, _ completion: @escaping Completion) {
        flatFeed.client.delete(reactionId: reaction.id) { result in
            if result.error == nil {
                var activity = activity
                activity.deleteOwnReaction(reaction)
            }
            
            completion(result.error)
        }
    }
    
    func remove(activity: Activity, _ completion: @escaping Completion) {
        flatFeed.remove(activityId: activity.id) { result in
            completion(result.error)
        }
    }
}
