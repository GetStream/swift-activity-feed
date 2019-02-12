//
//  ReactionPaginator.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 11/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import GetStream

public class ReactionPaginator<T: ReactionExtraDataProtocol, U: UserProtocol>: PaginatorProtocol {
    public typealias Completion = (_ error: Error?) -> Void
    
    let client: Client
    let activityId: String
    let reactionKind: ReactionKind
    
    public private(set) var items: [GetStream.Reaction<T, U>] = []
    public var next: Pagination = .none
    
    init(client: Client, activityId: String, reactionKind: ReactionKind) {
        self.client = client
        self.activityId = activityId
        self.reactionKind = reactionKind
    }
}

// MARK: - Pagiantion

extension ReactionPaginator {
    public func load(_ pagination: Pagination = .none, completion: @escaping Completion) {
        client.reactions(forActivityId: activityId,
                         kindOf: reactionKind,
                         extraDataTypeOf: T.self,
                         userTypeOf: U.self,
                         pagination: pagination,
                         withActivityData: false) { [weak self] result in
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
                                self.items.append(contentsOf: response.reactions)
                                self.next = response.next ?? .none
                            } catch let responseError {
                                error = responseError
                            }
                            
                            DispatchQueue.main.async { completion(error) }
        }
    }
}
