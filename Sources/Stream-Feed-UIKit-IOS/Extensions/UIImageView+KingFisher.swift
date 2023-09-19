//
//  File.swift
//  
//
//  Created by Sherif Shokry on 29/05/2023.
//

import Kingfisher
import UIKit
import AVFoundation

extension UIImageView {
    func loadImage(from imageResource: KF.ImageResource?, placeholder: UIImage? = nil, displayLoader: Bool = true,loaderStyle: UIActivityIndicatorView.Style = .medium, loaderColor: UIColor = .gray, isGIF: Bool = false, onComplete: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) {
        guard let imageResource = imageResource else { return }
        if displayLoader {
            let customIndicator = KingFisherCustomIndicator()
            customIndicator.activityIndicatorStyle = loaderStyle
            customIndicator.activityIndicatorColor = loaderColor

            self.kf.indicatorType = .custom(indicator: customIndicator)
        }
        var imageOptions: KingfisherOptionsInfo = [
            .scaleFactor(UIScreen.main.scale),
            .transition(.fade(0.2)),
            .cacheOriginalImage,
            .loadDiskFileSynchronously]
        if isGIF == false {
            imageOptions.insert(.processor(DownsamplingImageProcessor(size: self.frame.size)), at: 0)
        }
        self.kf.cancelDownloadTask()
        self.kf.setImage(with: imageResource, placeholder: placeholder, options: imageOptions) { (result: Result<RetrieveImageResult, KingfisherError>) in
            onComplete?(result)
        }
    }
}

extension UIButton {
    func loadImage(from urlString: String?, placeholder: UIImage? = nil, displayLoader: Bool = true,loaderStyle: UIActivityIndicatorView.Style = .medium, loaderColor: UIColor = .gray, isGIF: Bool = false, onComplete: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) {
        guard let url = URL(string: urlString ?? "") else { return }
        
        var imageOptions: KingfisherOptionsInfo = [
            .scaleFactor(UIScreen.main.scale),
            .transition(.fade(0.2)),
            .cacheOriginalImage,
            .loadDiskFileSynchronously]
        if isGIF == false {
            imageOptions.insert(.processor(DownsamplingImageProcessor(size: self.frame.size)), at: 0)
        }
        self.kf.setImage(with: url, for: .normal, placeholder: placeholder, options: imageOptions, completionHandler:  { (result: Result<RetrieveImageResult, KingfisherError>) in
            onComplete?(result)
        })
    }
}


class KingFisherCustomIndicator: Indicator {

    var activityIndicatorStyle: UIActivityIndicatorView.Style = .medium
    var activityIndicatorColor: UIColor = .gray
    lazy var view: IndicatorView = {
        let view = UIActivityIndicatorView(style: activityIndicatorStyle)
        view.color = activityIndicatorColor
        return view
    }()
    deinit {
        DispatchQueue.mainAsyncIfNeeded { [weak view] in
            view?.removeFromSuperview()
        }
    }
    func startAnimatingView() {
        (view as! UIActivityIndicatorView).startAnimating()
    }

    func stopAnimatingView() {
        (view as! UIActivityIndicatorView).stopAnimating()
    }

}
