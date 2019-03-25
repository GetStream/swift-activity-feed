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
    func updateOpenGraphData()
}

public final class EditPostPresenter {
    let flatFeed: FlatFeed
    let activity: Activity?
    private weak var view: EditPostViewable?
    private var detectedURL: URL?
    private(set) var ogData: OGResponse?
    
    var images: [UIImage] = []
    
    private(set) lazy var dataDetectorWorker: DataDetectorWorker? = try? DataDetectorWorker(types: .link) { [weak self]  in
        self?.updateOpenGraph($0)
    }
    
    private(set) lazy var openGraphWorker = OpenGraphWorker() { [weak self] url, openGraphData, error in
        if let self = self, error == nil {
            self.detectedURL = url
            self.ogData = openGraphData
            self.view?.updateOpenGraphData()
        }
    }
    
    init(flatFeed: FlatFeed, view: EditPostViewable, activity: Activity? = nil) {
        self.flatFeed = flatFeed
        self.view = view
        self.activity = activity
    }
    
    public func save(_ text: String?, completion: @escaping (_ error: Error?) -> Void) {
        guard User.current != nil else {
            completion(nil)
            return
        }
        
        if images.count > 0 {
            saveWithImages(text: text, completion: completion)
        } else {
            saveActivity(text: text, completion: completion)
        }
    }
    
    private func saveWithImages(text: String?, completion: @escaping (_ error: Error?) -> Void) {
        File.files(from: images, process: { File(name: "image\($0)", jpegImage: $1) }) { [weak self] files in
            self?.flatFeed.client.upload(images: files) { result in
                if let imageURLs = try? result.get() {
                    self?.saveActivity(text: text, imageURLs: imageURLs, completion: completion)
                } else if let error = result.error {
                    completion(error)
                }
            }
        }
    }
    
    private func saveActivity(text: String?, imageURLs: [URL] = [], completion: @escaping (_ error: Error?) -> Void) {
        guard let user = User.current, (text != nil || imageURLs.count > 0) else {
            completion(nil)
            return
        }
        
        let activity: Activity
        let attachment = ActivityAttachment()
        var imageURLs = imageURLs
        
        if let imageURL = imageURLs.first {
            imageURLs.removeFirst()
            activity = Activity(actor: user, verb: .post, object: .image(imageURL))
            activity.text = text
        } else if let text = text {
            activity = Activity(actor: user, verb: .post, object: .text(text))
        } else {
            completion(nil)
            return
        }
        
        if imageURLs.count > 0 {
            attachment.imageURLs = imageURLs
            activity.attachment = attachment
        }
        
        if let ogData = ogData {
            attachment.openGraphData = ogData
            activity.attachment = attachment
        }
        
        flatFeed.add(activity) { completion($0.error) }
    }
}

extension EditPostPresenter {
    private func updateOpenGraph(_ dataDetectorURLItems: [DataDetectorURLItem]) {
        view?.underlineLinks(with: dataDetectorURLItems)
        
        guard let item = dataDetectorURLItems.first(where: { !openGraphWorker.isBadURL($0.url) }) else {
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
