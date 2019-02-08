//
//  NSAttributedString+Extensions.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 28/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

extension NSAttributedString {
    /// Apply a font attribute for the full length of string.
    public func applyedFont(_ font: UIFont?) -> NSAttributedString {
        guard let font = font else {
            return self
        }
        
        let mutableString = NSMutableAttributedString(attributedString: self)
        mutableString.applyFont(font)
        return NSAttributedString(attributedString: mutableString)
    }
    
    /// Apply a paragraph style for the full length of string.
    public func applyedParagraphStyle(_ process: (_ style: NSMutableParagraphStyle) -> Void) -> NSAttributedString {
        let mutableString = NSMutableAttributedString(attributedString: self)
        mutableString.applyParagraphStyle(process)
        return NSAttributedString(attributedString: mutableString)
    }
}

extension NSMutableAttributedString {
    /// Apply a font attribute for the full length of string.
    public func applyFont(_ font: UIFont?) {
        if let font = font {
            addAttribute(.font, value: font, range: NSRange(location: 0, length: length))
        }
    }
    
    /// Apply a paragraph style for the full length of string.
    public func applyParagraphStyle(_ process: (_ style: NSMutableParagraphStyle) -> Void) {
        let paragraphStyle = NSMutableParagraphStyle()
        process(paragraphStyle)
        addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: length))
    }
}

extension String {
    /// Create an attributed string with the given style block of attributes.
    public func attributedString(_ style: (_ mutableAttributedString: NSMutableAttributedString) -> Void) -> NSAttributedString {
        let mutableString = NSMutableAttributedString(string: self)
        style(mutableString)
        return NSAttributedString(attributedString: mutableString)
    }
}
