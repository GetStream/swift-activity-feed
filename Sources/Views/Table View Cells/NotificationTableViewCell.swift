//
//  NotificationTableViewCell.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 15/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

public final class NotificationTableViewCell: BaseTableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var unseenView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
    public var isUnseen: Bool = false {
        didSet { unseenView.isHidden = !isUnseen }
    }
    
    public override func reset() {
        avatarImageView.image = nil
        titleLabel.attributedText = nil
        dateLabel.text = nil
        isUnseen = false
    }
    
    public func title(with title: String, subtitle: String) {
        let attributedText = NSMutableAttributedString(string: title, attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .bold)])
        let subtitle = NSAttributedString(string: " \(subtitle)", attributes: [.font: UIFont.systemFont(ofSize: 12)])
        attributedText.append(subtitle)
        
        attributedText.applyParagraphStyle { paragraphStyle in
            paragraphStyle.lineHeightMultiple = 1.2
        }
        
        titleLabel.attributedText = attributedText
    }
}
