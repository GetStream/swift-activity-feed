//
//  EditPostPresenter.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 28/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import GetStream

protocol EditPostViewable: class {
    func underlineLinks(with dataDetectorURLItems: [DataDetectorURLItem])
    func updateImages()
    func updateOpenGraphData()
}

public final class EditPostPresenter {
    private let activity: Activity?
    private let client: Client
    private weak var view: EditPostViewable?
    private var detectedURL: URL?
    private(set) var ogData: OGResponse?
    
    var images: [UIImage] = []
    
    private(set) lazy var dataDetectorWorker: DataDetectorWorker? = try? DataDetectorWorker(types: .link) { [weak self]  in
        self?.updateOpenGraph($0)
    }
    
    private(set) lazy var openGraphWorker: OpenGraphWorker = OpenGraphWorker(client: client) { [weak self] url, response in
        if let self = self {
            self.detectedURL = url
            self.ogData = response
            self.view?.updateOpenGraphData()
        }
    }
    
    init(client: Client, view: EditPostViewable, activity: Activity?) {
        self.client = client
        self.view = view
        self.activity = activity
    }
    
    public func save(_ text: String?, completion: @escaping (_ error: Error?) -> Void) {
        guard let user = UIApplication.shared.appDelegate.currentUser, let text = text else {
            completion(nil)
            return
        }
        
        let activity = Activity(actor: user, verb: .post, object: .text(text))
        
        if let ogData = ogData {
            let attachment = ActivityAttachment()
            attachment.openGraphData = ogData
            activity.attachments = attachment
        }
        
        user.add(activity: activity) { completion($0) }
    }
}

extension EditPostPresenter {
    private func updateOpenGraph(_ dataDetectorURLItems: [DataDetectorURLItem]) {
        view?.underlineLinks(with: dataDetectorURLItems)
        
        var dataDetectorURLItem: DataDetectorURLItem?
        
        for item in dataDetectorURLItems {
            if !openGraphWorker.isBadURL(item.url) {
                dataDetectorURLItem = item
                break
            }
        }
        
        guard let item = dataDetectorURLItem else {
            detectedURL = nil
            ogData = nil
            openGraphWorker.cancel()
            view?.updateOpenGraphData()
            return
        }
        
        if let detectedURL = detectedURL, detectedURL == item.url {
            return
        }
        
        detectedURL = nil
        ogData = nil
        view?.updateOpenGraphData()
        openGraphWorker.dispatch(item.url)
    }
}
