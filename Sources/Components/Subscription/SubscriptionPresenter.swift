//
//  SubscriptionPresenter.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 18/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import GetStream
import Faye

public final class SubscriptionPresenter<T: ActivityProtocol> {
    
    public let feed: Feed
    private var subscribedChannel: SubscribedChannel?
    private var subscribers: [UUID: Subscription<T>] = [:]
    
    public init(feed: Feed) {
        self.feed = feed
        Faye.Client.logsEnabled = true
    }
}

// MARK: - Updates

extension SubscriptionPresenter {
    /// Subscribe to the feed updates.
    /// Keep `SubscriptionId` until subscription is needed.
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
