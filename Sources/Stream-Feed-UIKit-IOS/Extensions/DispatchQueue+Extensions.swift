//
//  File.swift
//  
//
//  Created by Sherif Shokry on 06/08/2023.
//

import Foundation

extension DispatchQueue {
    static func mainAsyncIfNeeded(execute work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            main.async(execute: work)
        }
    }
}
