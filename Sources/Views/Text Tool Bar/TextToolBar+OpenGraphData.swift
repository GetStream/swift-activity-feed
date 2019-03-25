//
//  TextToolBar+OpenGraphData.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 25/03/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import GetStream

extension TextToolBar {
    
    func updateOpenGraph(_ dataDetectorURLItems: [DataDetectorURLItem]) {
        underlineLinks(with: dataDetectorURLItems)
        
        guard let item = dataDetectorURLItems.first(where: { !openGraphWorker.isBadURL($0.url) }) else {
            detectedURL = nil
            openGraphData = nil
            openGraphWorker.cancel()
            updateOpenGraphPreview()
            return
        }
        
        if let detectedURL = detectedURL, detectedURL == item.url {
            return
        }
        
        detectedURL = nil
        openGraphData = nil
        updateOpenGraphPreview()
        openGraphWorker.dispatch(item.url)
    }
    
    func underlineLinks(with dataDetectorURLItems: [DataDetectorURLItem]) {
        let text = NSMutableAttributedString(string: textView.attributedText.string, attributes: textViewTextAttributes)
        
        dataDetectorURLItems.forEach { item in
            if !openGraphWorker.isBadURL(item.url) {
                text.addAttributes([.underlineStyle: NSUnderlineStyle.thick.rawValue,
                                    .underlineColor: linksHighlightColor],
                                   range: item.range.range)
            }
        }
        
        textView.attributedText = NSAttributedString(attributedString: text)
    }
    
    func updateOpenGraphPreview() {
        if let ogData = openGraphData {
            openGraphPreview.update(with: ogData)
        } else {
            if openGraphPreviewContainer.isHidden {
                return
            }
            
            openGraphPreview.reset()
        }
        
        openGraphPreviewContainer.isHidden = openGraphData == nil
        updateTextHeightIfNeeded()
    }
}
