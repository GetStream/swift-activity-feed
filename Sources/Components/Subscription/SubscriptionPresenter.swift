//
//  SubscriptionPresenter.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 18/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import GetStream
import Faye

/// A subscription presenter.
public final class SubscriptionPresenter<T: ActivityProtocol> {
    
    /// A feed.
    public let feed: Feed
    private var subscribedChannel: SubscribedChannel?
    private var subscribers: [UUID: Subscription<T>] = [:]
    
    /// Creates an instance of the subscription presenter.
    public init(feed: Feed) {
        self.feed = feed
    }
}

// MARK: - Updates

extension SubscriptionPresenter {
    /// Subscribe to the feed updates.
    /// Keep `SubscriptionId` until subscription is needed. Set it to `nil` to unsubscribe.
    ///
    /// - Parameter subscription: a subscription block.
    /// - Returns: a subsction id. See `SubscriptionId`.
    public func subscribe(_ subscription: @escaping Subscription<T>) -> SubscriptionId {
        let subscriptionId = SubscriptionId() { [weak self] uuid in
            DispatchQueue.main.async {
                self?.subscribers.removeValue(forKey: uuid)
            }
        }
        
        subscribers[subscriptionId.uuid] = subscription
        
        if subscribedChannel != nil {
            return subscriptionId
        }
        
        subscribedChannel = feed.subscribe(typeOf: T.self) { [weak self] result in
            DispatchQueue.main.async {
                self?.subscribers.forEach { _, subscription in
                    subscription(result)
                }
            }
        }
        
        return subscriptionId
    }
}

/// A subscription id to keep the subscription alive.
/// Set it to `nil` to unsubscribe.
public final class SubscriptionId {
    fileprivate typealias Cleaner = (_ uuid: UUID) -> Void
    fileprivate let uuid = UUID()
    private let cleaner: Cleaner
    
    fileprivate init(_ cleaner: @escaping Cleaner) {
        self.cleaner = cleaner
    }
    
    deinit {
        cleaner(uuid)
    }
}
