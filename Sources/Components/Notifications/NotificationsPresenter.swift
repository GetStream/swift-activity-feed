//
//  NotificationsPresenter.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 15/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import GetStream

/// A notifications presenter.
public final class NotificationsPresenter<T: ActivityProtocol>: PaginatorProtocol {
    /// A completion block.
    public typealias Completion = (_ error: Error?) -> Void
    
    /// A notification feed.
    public let notificationFeed: NotificationFeed
    /// A notification items.
    public private(set) var items: [NotificationGroup<T>] = []
    /// A pagination for the next page.
    public var next: Pagination = .none
    /// A mark option. See `FeedMarkOption`.
    public var markOption: FeedMarkOption = .none
    
    /// A number of unseen notifications.
    public private(set) var unseenCount: Int = 0
    /// A number of unread notifications.
    public private(set) var unreadCount: Int = 0
    
    /// A subscription presenter. See `SubscriptionPresenter`.
    public let subscriptionPresenter: SubscriptionPresenter<T>
    
    /// Create an instance of notifications presenter.
    public init(_ notificationFeed: NotificationFeed) {
        self.notificationFeed = notificationFeed
        self.subscriptionPresenter = SubscriptionPresenter(feed: notificationFeed)
    }
}

extension NotificationsPresenter {
    /// Resets the notifications loaded so far.
    public func reset() {
        items = []
    }
    
    /// Load notifications with a given pagination options.
    public func load(_ pagination: Pagination = .none, completion: @escaping Completion) {
        notificationFeed.get(typeOf: T.self, pagination: pagination, markOption: markOption) { [weak self] result in
            guard let self = self else {
                return
            }
            
            if case .none = pagination {
                self.items = []
                self.next = .none
            }
            
            var error: Error?
            self.markOption = .none
            
            do {
                let response = try result.get()
                self.items.append(contentsOf: response.results)
                self.next = response.next ?? .none
                self.unseenCount = response.unseenCount ?? 0
                self.unreadCount = response.unreadCount ?? 0
            } catch let responseError {
                error = responseError
            }
            
            DispatchQueue.main.async { completion(error) }
        }
    }
}
