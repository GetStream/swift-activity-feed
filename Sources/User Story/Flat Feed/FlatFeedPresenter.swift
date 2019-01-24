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

// MARK: - Reaction Presenter

extension FlatFeedPresenter: ReactionPresenterProtocol {
    
    public func addReaction<T: EnhancedActivity>(for activity: T,
                                                 kindOf kind: ReactionKind,
                                                 targetsFeedIds: [FeedId],
                                                 _ completion: @escaping (Result<T, ClientError>) -> Void) {
        flatFeed.client.add(reactionTo: activity.id, kindOf: kind, targetsFeedIds: targetsFeedIds) { result in
            if let reaction = try? result.get() {
                var activity = activity
                activity.addOwnReaction(reaction)
                completion(.success(activity))
                
            } else if let error = result.error {
                completion(.failure(error))
            }
        }
    }
    
    public func remove<T: EnhancedActivity>(reaction: Reaction<ReactionNoExtraData>,
                                            activity: T,
                                            _ completion: @escaping (Result<T, ClientError>) -> Void) {
        flatFeed.client.delete(reactionId: reaction.id) { result in
            if result.error == nil {
                var activity = activity
                activity.deleteOwnReaction(reaction)
                completion(.success(activity))
                
            } else if let error = result.error {
                completion(.failure(error))
            }
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
