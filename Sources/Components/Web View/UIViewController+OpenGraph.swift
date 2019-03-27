//
//  UIViewController+OpenGraph.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 14/03/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import GetStream

extension UIViewController {
    
    /// Presents the Open Graph data in a `WebViewController`.
    public func showOpenGraphData(with ogData: OGResponse?, animated: Bool = true) {
        guard let ogData = ogData else {
            return
        }
        
        let webViewController = WebViewController()
        webViewController.url = ogData.url
        webViewController.title = ogData.title
        present(UINavigationController(rootViewController: webViewController), animated: animated)
    }
}
