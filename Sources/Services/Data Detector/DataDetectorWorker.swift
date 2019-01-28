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
    private let dispatchQueue = DispatchQueue(label: "io.getstream.DataDetectorWorker", qos: .default)
    private let completion: Completion
    
    init(types: NSTextCheckingResult.CheckingType, completion: @escaping Completion) throws {
        detector = try NSDataDetector(types: types.rawValue)
        self.completion = completion
    }
    
    public func match(_ text: String) {
        dispatchQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            var urls: [DataDetectorURLItem] = []
            let matches = self.detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
            
            for match in matches {
                guard let range = Range(match.range, in: text) else {
                    continue
                }
                
                if let url = URL(string: String(text[range])) {
                    urls.append(DataDetectorURLItem(url: url, range: range))
                }
            }
            
            DispatchQueue.main.async { self.completion(urls) }
        }
    }
}

public struct DataDetectorURLItem {
    let url: URL
    let range: Range<String.Index>
}
