//
//  OpenGraphWorker.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 28/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import GetStream

/// An open graph worker.
/// Requests a given URL to scrape the Open Graph data.
public final class OpenGraphWorker {
    /// A Open Graph data completion block.
    public typealias Completion = (_ url: URL, _ response: OGResponse?, _ error: Error?) -> Void
    
    private let completion: Completion
    private let dispatchQueue = DispatchQueue(label: "io.getstream.OpenGraphWorker")
    private var dispatchWorkItem: DispatchWorkItem?
    private let callbackQueue: DispatchQueue
    private var cache: [URL: OGResponse] = [:]
    private var cacheBadURLs: [URL] = []
    
    /// Create a Open Graph worker with a given completion block.
    public init(callbackQueue: DispatchQueue = .main, completion: @escaping Completion) {
        self.completion = completion
        self.callbackQueue = callbackQueue
    }
    
    /// Dispatch a given URL.
    public func dispatch(_ url: URL, delay: DispatchTimeInterval = .seconds(1)) {
        callbackQueue.async { [weak self] in self?.scheduleWork(for: url, delay: delay) }
    }
    
    /// Cancel the work.
    public func cancel() {
        callbackQueue.async { [weak self] in self?.cancelWork() }
    }
    
    /// Checks cache with bad URL's, which returned an error on request.
    public func isBadURL(_ url: URL) -> Bool {
        return cacheBadURLs.contains(url)
    }
}

// MARK: - Work

extension OpenGraphWorker {
    
    private func scheduleWork(for url: URL, delay: DispatchTimeInterval) {
        self.cancelWork()
        
        if let response = cache[url] {
            completion(url, response, nil)
            return
        }
        
        let dispatchWorkItem = DispatchWorkItem { [weak self] in self?.parse(url) }
        dispatchQueue.asyncAfter(deadline: .now() + delay, execute: dispatchWorkItem)
        self.dispatchWorkItem = dispatchWorkItem
    }
    
    private func cancelWork() {
        dispatchWorkItem?.cancel()
        dispatchWorkItem = nil
    }
    
    private func parse(_ url: URL) {
        Client.shared.og(url: url) { [weak self] result in
            self?.callbackQueue.async {
                guard let self = self else {
                    return
                }
                
                if let response = try? result.get() {
                    self.cache[url] = response
                    self.completion(url, response, nil)
                    
                } else if let error = result.error {
                    print("ℹ️ OpenGraph failed to retrieve \(url): \(error)")
                    self.cacheBadURLs.append(url)
                    self.completion(url, nil, error)
                }
            }
        }
    }
}
