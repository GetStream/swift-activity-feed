//
//  OpenGraphWorker.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 28/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import GetStream

public final class OpenGraphWorker {
    public typealias Completion = (_ url: URL, _ response: OGResponse) -> Void
    
    private let client: Client
    private let completion: Completion
    private let dispatchQueue = DispatchQueue(label: "io.getstream.OpenGraphWorker")
    private var dispatchWorkItem: DispatchWorkItem?
    private let callbackQueue: DispatchQueue
    private var cache: [URL: OGResponse] = [:]
    private var cacheBad: [URL] = []
    
    public init(client: Client, callbackQueue: DispatchQueue = .main, completion: @escaping Completion) {
        self.client = client
        self.completion = completion
        self.callbackQueue = callbackQueue
    }
    
    public func dispatch(_ url: URL, delay: DispatchTimeInterval = .seconds(1)) {
        callbackQueue.async { [weak self] in self?.scheduleWork(for: url, delay: delay) }
    }
    
    public func cancel() {
        callbackQueue.async { [weak self] in self?.cancelWork() }
    }
    
    public func isBadURL(_ url: URL) -> Bool {
        return cacheBad.contains(url)
    }
}

// MARK: - Work

extension OpenGraphWorker {
    
    private func scheduleWork(for url: URL, delay: DispatchTimeInterval) {
        self.cancelWork()
        
        if let response = cache[url] {
            completion(url, response)
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
        client.og(url: url) { [weak self] result in
            self?.callbackQueue.async {
                guard let self = self else {
                    return
                }
                
                if let response = try? result.get() {
                    self.cache[url] = response
                    self.completion(url, response)
                    
                } else if let error = result.error {
                    print("ℹ️ OpenGraph failed to retrieve \(url): \(error)")
                    self.cacheBad.append(url)
                }
            }
        }
    }
}
