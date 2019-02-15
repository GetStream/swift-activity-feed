//
//  AddingImageCollectionViewCell.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 29/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import Reusable

public final class AddingImageCollectionViewCell: UICollectionViewCell, NibReusable {
    public static let height: CGFloat = 90

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var removeButton: UIButton!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }
    
    public override func prepareForReuse() {
        reset()
        super.prepareForReuse()
    }
    
    private func reset() {
        imageView.image = nil
        removeButton.removeTap()
    }
}
