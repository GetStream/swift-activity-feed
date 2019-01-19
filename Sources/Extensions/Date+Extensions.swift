//
//  Date+Extensions.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 18/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

extension Date {
    public var relative: String {
        let timeInterval = -self.timeIntervalSinceNow
        
        if timeInterval < 43_200 {
            return DateFormatter.time.string(from: self)
        } else if timeInterval < 129_600 {
            return "Yesterday, \(DateFormatter.time.string(from: self))"
        } else if timeInterval < 518_400 {
            return DateFormatter.weekDay.string(from: self)
        }
        
        return DateFormatter.short.string(from: self)
    }
}

extension DateFormatter {
    
    public static let time: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
    
    public static let short: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter
    }()
    
    public static let weekDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()
}
