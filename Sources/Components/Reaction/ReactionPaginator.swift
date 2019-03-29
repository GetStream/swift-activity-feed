//
//  ReactionPaginator.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 11/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import GetStream

/// A reaction paginator.
public final class ReactionPaginator<T: ReactionExtraDataProtocol, U: UserProtocol>: PaginatorProtocol {
    /// A completion block.
    public typealias Completion = (_ error: Error?) -> Void
    
    /// An activity id of reactions.
    public let activityId: String
    /// A reaction kind.
    public let reactionKind: ReactionKind
    
    /// Reaction items.
    public private(set) var items: [GetStream.Reaction<T, U>] = []
    /// A pagination for the next page.
    public var next: Pagination = .none
    
    /// Create a reaction paginator for a given activity id and reaction kind.
    public init(activityId: String, reactionKind: ReactionKind) {
        self.activityId = activityId
        self.reactionKind = reactionKind
    }
}

// MARK: - Pagiantion

extension ReactionPaginator {
    /// Load reactions with a given pagination options.
    public func load(_ pagination: Pagination = .none, completion: @escaping Completion) {
        Client.shared.reactions(forActivityId: activityId,
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
