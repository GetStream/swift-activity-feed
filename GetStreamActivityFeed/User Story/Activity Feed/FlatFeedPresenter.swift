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
    
    private(set) var activities: [T] = []
    private var next: Pagination = .none
    
    init(flatFeed: FlatFeed) {
        self.flatFeed = flatFeed
    }
    
    public func loadActivities(pagination: Pagination = .none, completion: @escaping Completion) {
        if case .none = pagination {
            activities = []
            next = .none
        }
        
        flatFeed.get(typeOf: T.self, pagination: pagination) { [weak self] result in
            guard let self = self else {
                return
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
