//
//  BellButton.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 18/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import SnapKit

public final class BellButton: UIButton {
    
    public private(set) lazy var counterLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.backgroundColor = Appearance.Color.red
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        addSubview(label)
        
        label.snp.makeConstraints { make in
            make.height.equalTo(16)
            make.width.greaterThanOrEqualTo(16)
            make.top.equalToSuperview().offset(-6)
            make.left.equalTo(snp.right).offset(-6)
        }
        
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        setTitle(nil, for: .normal)
        setImage(.bellIcon, for: .normal)
    }
    
    public var count: Int {
        get { return Int(counterLabel.text?.trimmingCharacters(in: CharacterSet(charactersIn: "_")) ?? "0") ?? 0 }
        set {
            guard newValue > 0 else {
                counterLabel.text = nil
                counterLabel.isHidden = true
                return
            }
            
            let space = NSAttributedString(string: "_", attributes: [.foregroundColor: Appearance.Color.red])
            let attributedText = NSMutableAttributedString(attributedString: space)
            attributedText.append(NSAttributedString(string: String(newValue), attributes: [.foregroundColor: UIColor.white]))
            attributedText.append(space)
            attributedText.applyFont(.systemFont(ofSize: 12))
            
            counterLabel.attributedText = attributedText
            counterLabel.isHidden = false
        }
    }
}
