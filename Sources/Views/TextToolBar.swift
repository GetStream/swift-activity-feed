//
//  TextToolBar.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 07/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import SnapKit

open class TextToolBar: UIView {
    public static let height: CGFloat = 80
    public static let avatarWidth: CGFloat = 50
    
    public var placeholderText = "" {
        didSet {
            addPlaceholder()
        }
    }
    
    public private(set) lazy var avatarView: AvatarView = {
        let avatarView = AvatarView()
        avatarView.shadowRadius = 6
        avatarView.cornerRadius = TextToolBar.avatarWidth / 2
        avatarView.placeholder = .userIcon
        avatarView.tintColor = .gray
        avatarView.alpha = 0.8
        addSubview(avatarView)
        
        avatarView.snp.makeConstraints({ make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset((TextToolBar.height - TextToolBar.avatarWidth) / 2)
            make.width.height.equalTo(TextToolBar.avatarWidth)
        })
        
        return avatarView
    }()
    
    public private(set) lazy var textView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.backgroundColor = .clear
        addSubview(textView)
        
        textView.snp.makeConstraints({ make in
            make.top.equalTo(TextToolBar.height / 2 - 17)
            make.bottom.equalToSuperview()
            make.right.equalTo(sendButton.snp.left).offset(-8)
            make.left.equalTo(avatarView.snp.right).offset(16)
        })
        
        return textView
    }()
    
    public private(set) lazy var sendButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("Send", for: .normal)
        button.setTitleColor(Appearance.Color.blue, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        button.sizeToFit()
        button.isEnabled = false
        addSubview(button)
        
        button.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-8)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(button.frame.size.width + 16)
        }
        
        return button
    }()
    
    @IBOutlet public weak var bottomConstraint: NSLayoutConstraint?
    private weak var heightConstraint: NSLayoutConstraint?

    public static func textToolBar() -> TextToolBar {
        return TextToolBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 46))
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = UIColor(white: 0.95, alpha: 1)
        textView.font = .systemFont(ofSize: 15)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardUpdated(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    public func addToSuperview(_ view: UIView) {
        view.addSubview(self)
        
        snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width)
            heightConstraint = make.height.equalTo(TextToolBar.height).constraint.layoutConstraints.first
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    public func addPlaceholder() {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = .lightGray
            sendButton.isEnabled = false
        } else {
            textView.textColor = .black
            sendButton.isEnabled = true
        }
    }
    
    public func clearPlaceholder() {
        if textView.text == placeholderText {
            textView.text = ""
            textView.textColor = .black
        }
    }
}

// MARK: - Keyboard Events

extension TextToolBar {
    @objc func keyboardUpdated(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let value = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let view = superview else {
            return
        }
        
        snp.updateConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-value.cgRectValue.height)
        }
        
        if let durationNumber = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {
            UIView.animate(withDuration: durationNumber.doubleValue,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 0,
                           options: [],
                           animations: { self.layoutIfNeeded() })
        } else {
            layoutIfNeeded()
        }
    }
}
