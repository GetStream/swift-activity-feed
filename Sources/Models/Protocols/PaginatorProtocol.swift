//
//  PaginatorProtocol.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 11/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import GetStream

protocol PaginatorProtocol {
    associatedtype ItemType
    typealias Completion = (_ error: Error?) -> Void
    
    var items: [ItemType] { get }
    var next: Pagination { get }
    var hasNext: Bool { get }
    var count: Int { get }
    var total: Int { get }
    
    func load(_ pagination: Pagination, completion: @escaping Completion)
    
    func loadNext(completion: @escaping Completion)
}

extension PaginatorProtocol {
    
    public var hasNext: Bool {
        if case .none = next {
            return false
        }
        
        return true
    }
    
    public var count: Int {
        return items.count
    }
    
    public func loadNext(completion: @escaping Completion) {
        load(next, completion: completion)
    }
}
