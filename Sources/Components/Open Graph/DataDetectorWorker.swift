//
//  DataDetectorWorker.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 25/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

public final class DataDetectorWorker {
    public typealias Completion = (_ urls: [DataDetectorURLItem]) -> Void
    
    private let detector: NSDataDetector
    private let dispatchQueue = DispatchQueue(label: "io.getstream.DataDetectorWorker")
    private let completion: Completion
    private let callbackQueue: DispatchQueue
    
    init(types: NSTextCheckingResult.CheckingType, callbackQueue: DispatchQueue = .main, completion: @escaping Completion) throws {
        detector = try NSDataDetector(types: types.rawValue)
        self.completion = completion
        self.callbackQueue = callbackQueue
    }
    
    public func match(_ text: String) {
        dispatchQueue.async { [weak self] in self?.matchInBackground(text) }
    }
    
    private func matchInBackground(_ text: String) {
        var urls: [DataDetectorURLItem] = []
        let matches: [NSTextCheckingResult] = detector.matches(in: text,
                                                               options: [],
                                                               range: NSRange(location: 0, length: text.utf16.count))
        
        for match in matches {
            guard let range = Range(match.range, in: text) else {
                continue
            }
            
            var urlString = String(text[range])
            
            if urlString.hasPrefix("//") {
                urlString = "https:\(urlString)"
            }
            
            if !urlString.lowercased().hasPrefix("http") {
                urlString = "https://\(urlString)"
            }
            
            if let url = URL(string: urlString) {
                urls.append(DataDetectorURLItem(url: url, range: range))
            }
        }
        
        callbackQueue.async { [weak self] in self?.completion(urls) }
    }
}

public struct DataDetectorURLItem {
    let url: URL
    let range: Range<String.Index>
}
