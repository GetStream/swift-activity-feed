//
//  ActivityRouter.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 01/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import GetStream

public struct ActivityRouter {
    
    let viewController: UIViewController
    var profileBuilder: ProfileBuilder?
    
    init(viewController: UIViewController, profileBuilder: ProfileBuilder?) {
        self.viewController = viewController
        self.profileBuilder = profileBuilder
    }
    
    public func show(user: User) {
        if let profileViewCotroller = profileBuilder?.profileViewController(user: user) {
            profileViewCotroller.builder = profileBuilder
            viewController.navigationController?.pushViewController(profileViewCotroller, animated: true)
        }
    }
    
    public func show(ogData: OGResponse?) {
        guard let ogData = ogData else {
            return
        }
        
        let webViewController = WebViewController()
        webViewController.url = ogData.url
        webViewController.title = ogData.title
        viewController.present(UINavigationController(rootViewController: webViewController), animated: true)
    }
    
    public func show(attachmentImageURLs: [URL]?) {
        guard let attachmentImageURLs = attachmentImageURLs else {
            return
        }
        
        let imageGalleryViewController = ImageGalleryViewController()
        imageGalleryViewController.imageURLs = attachmentImageURLs
        viewController.present(imageGalleryViewController, animated: true)
    }
}
