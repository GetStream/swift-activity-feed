//
//  NotificationsPresenter.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 15/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import GetStream

public final class NotificationsPresenter<T: ActivityProtocol>: PaginatorProtocol {
    
    public typealias Completion = (_ error: Error?) -> Void
    
    public let notificationFeed: NotificationFeed
    public private(set) var items: [NotificationGroup<T>] = []
    public var next: Pagination = .none
    public private(set) var total: Int = 0
    public var markOption: FeedMarkOption = .none
    
    public private(set) var unseenCount: Int = 0
    public private(set) var unreadCount: Int = 0
    
    public let subscriptionPresenter: SubscriptionPresenter<T>
    
    public init(_ notificationFeed: NotificationFeed) {
        self.notificationFeed = notificationFeed
        self.subscriptionPresenter = SubscriptionPresenter(feed: notificationFeed)
    }
}

extension NotificationsPresenter {
    public func load(_ pagination: Pagination = .none, completion: @escaping Completion) {
        notificationFeed.get(typeOf: T.self, markOption: markOption) { [weak self] result in
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
