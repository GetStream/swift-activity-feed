//
//  OpenGraphTableViewCell.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 28/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import Reusable
import GetStream
import Nuke

public final class OpenGraphTableViewCell: UITableViewCell, NibReusable {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var previewImageView: UIImageView!
    @IBOutlet weak var previewImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }
    
    public override func prepareForReuse() {
        reset()
        super.prepareForReuse()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = Appearance.Color.lightGray.cgColor
    }
    
    private func reset() {
        previewImageView.image = .imageIcon
        previewImageView.contentMode = .center
        previewImageView.backgroundColor = Appearance.Color.lightGray
        previewImageView.isHidden = false
        previewImageWidthConstraint.constant = 100
        titleLabel.text = nil
        descriptionLabel.text = nil
    }
    
    public func updatePreviewImage(with url: URL?) {
        guard let url = url else {
            return
        }
        
        ImagePipeline.shared.loadImage(with: url.imageRequest(in: previewImageView)) { [weak self] result in
            guard let self = self else {
                return
            }
            
            if let response = try? result.get() {
                self.previewImageView.image = response.image
                self.previewImageView.contentMode = .scaleAspectFit
                self.previewImageView.backgroundColor = .white
            } else {
                self.previewImageWidthConstraint.constant = 0
                self.previewImageView.isHidden = true
            }
        }
    }
}

// MARK: - Stream Open Graph Request

extension OpenGraphTableViewCell {
    /// Updates the cell with a given Open Graph data.
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
}
