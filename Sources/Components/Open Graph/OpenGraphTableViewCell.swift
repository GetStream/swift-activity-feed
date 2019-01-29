//
//  OpenGraphTableViewCell.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 28/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import Reusable
import Nuke

public final class OpenGraphTableViewCell: UITableViewCell, NibReusable {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var previewImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
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
        titleLabel.text = nil
        descriptionLabel.text = nil
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        backgroundColor = isSelected ? Appearance.Color.lightGray : .white
        selectedBackgroundView?.backgroundColor = backgroundColor
    }
    
    public override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        setSelected(highlighted, animated: animated)
    }
    
    public func updatePreviewImage(with url: URL?) {
        guard let url = url else {
            return
        }
        
        ImagePipeline.shared.loadImage(with: url.imageRequest(in: previewImageView)) { [weak self] response, error in
            self?.previewImageView.image = response?.image
            self?.previewImageView.contentMode = .scaleAspectFit
            self?.previewImageView.backgroundColor = .white
        }
    }
}
