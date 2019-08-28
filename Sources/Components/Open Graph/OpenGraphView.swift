//
//  OpenGraphView.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 22/03/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import SnapKit
import Nuke
import GetStream

/// A view of Open Graph data.
public final class OpenGraphView: UIView {
    /// The default height.
    public static let height: CGFloat = 116
    
    private lazy var containerView: UIView = {
        let view = UIView(frame: .zero)
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = Appearance.Color.lightGray.cgColor
        view.addSubview(previewImageView)
        previewImageView.snp.makeConstraints { $0.left.top.equalToSuperview() }
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-16)
            previewImageToTitleConstraint = make.left.equalTo(previewImageView.snp.right).offset(8).priority(751).constraint
            make.left.equalToSuperview().offset(16).priority(.high)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
            make.bottom.lessThanOrEqualToSuperview().offset(-8)
        }
        
        return view
    }()
    
    private var previewImageToTitleConstraint: Constraint?
    
    private let previewImageView: UIImageView = {
        let imageView = UIImageView(image: .imageIcon)
        imageView.contentMode = .center
        imageView.tintColor = .black
        imageView.snp.makeConstraints { $0.width.height.equalTo(OpenGraphView.height - 16) }
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 2
        label.textColor = Appearance.Color.blue
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    /// Resets states of all child views.
    public func reset() {
        previewImageView.image = .imageIcon
        previewImageView.contentMode = .center
        previewImageView.isHidden = false
        previewImageToTitleConstraint?.update(priority: 751)
        titleLabel.text = nil
        descriptionLabel.text = nil
    }
}

extension OpenGraphView {
    
    /// Updates the view with a given Open Graph data.
    public func update(with ogData: OGResponse) {
        titleLabel.text = ogData.title
        descriptionLabel.text = ogData.description
        
        if let imageURLString = ogData.images?.first?.image {
            var imageURLString = imageURLString
            
            if imageURLString.hasPrefix("//") {
                imageURLString = "https:\(imageURLString)"
            }
            
            updatePreviewImage(with: URL(string: imageURLString))
        }
    }
    
    /// Loads the image with a given URL.
    private func updatePreviewImage(with url: URL?) {
        guard let url = url else {
            return
        }
        
        ImagePipeline.shared.loadImage(with: url.imageRequest(in: previewImageView)) { [weak self] response, error in
            guard let self = self else {
                return
            }
            
            if let image = response?.image {
                self.previewImageView.image = image
                self.previewImageView.contentMode = .scaleAspectFit
                self.previewImageToTitleConstraint?.update(priority: 751)
            } else {
                self.previewImageView.isHidden = true
                self.previewImageToTitleConstraint?.update(priority: .low)
            }
        }
    }
}
