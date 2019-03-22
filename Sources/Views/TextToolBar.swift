//
//  TextToolBar.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 07/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import SnapKit

public final class TextToolBar: UIView {
    public static let textContainerHeight: CGFloat = 80
    public static let textContainerMaxHeight: CGFloat = 200
    public static let avatarWidth: CGFloat = 50
    public static let replyContainerHeight: CGFloat = 30
    
    public static func make() -> TextToolBar {
        return TextToolBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: TextToolBar.textContainerHeight))
    }
    
    /// A stack view for containers.
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [replyContainer, textStackView])
        stackView.axis = .vertical
        stackView.backgroundColor = backgroundColor
        
        return stackView
    }()
    
    // MARK: - Text View Container
    private lazy var textStackView: UIStackView = {
        // 1. Avatar View
        let avatarContainer = UIView(frame: .zero)
        avatarContainer.snp.makeConstraints { $0.width.equalTo(TextToolBar.avatarWidth) }
        avatarContainer.addSubview(avatarView)
        avatarContainer.backgroundColor = backgroundColor
        
        avatarView.snp.makeConstraints({ make in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset((TextToolBar.textContainerHeight - TextToolBar.avatarWidth) / 2)
            make.width.height.equalTo(TextToolBar.avatarWidth)
        })
        
        // 2. Text View
        let textViewContainer = UIView(frame: .zero)
        textViewContainer.addSubview(textView)
        textViewContainer.backgroundColor = backgroundColor
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(TextToolBar.textContainerHeight / 2 - 17)
            make.bottom.equalToSuperview().offset(-8)
            make.left.right.equalToSuperview()
        }
        
        let stackView = UIStackView(arrangedSubviews: [avatarContainer, textViewContainer, sendButton])
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        stackView.axis = .horizontal
        stackView.spacing = 8
        
        return stackView
    }()
    
    public private(set) lazy var avatarView: AvatarView = {
        let avatarView = AvatarView()
        avatarView.shadowRadius = 6
        avatarView.cornerRadius = TextToolBar.avatarWidth / 2
        avatarView.placeholder = .userIcon
        avatarView.tintColor = .gray
        avatarView.alpha = 0.9
        return avatarView
    }()
    
    public private(set) lazy var textView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.font = .systemFont(ofSize: 15)
        textView.backgroundColor = backgroundColor
        textView.delegate = self
        return textView
    }()
    
    public private(set) lazy var placeholderLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .lightGray
        label.font = textView.font
        label.backgroundColor = backgroundColor
        textView.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.left.equalTo(textView.textContainer.lineFragmentPadding)
            make.top.equalTo(textView.textContainerInset.top)
            make.right.equalToSuperview()
        }
        
        return label
    }()
    
    public private(set) lazy var sendButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle(sendTitle, for: .normal)
        button.setTitleColor(Appearance.Color.blue, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        button.backgroundColor = backgroundColor
        return button
    }()
    
    public var text: String {
        get { return textView.text ?? "" }
        set {
            textView.text = newValue
            updatePlaceholder()
        }
    }
    
    public var showAvatar: Bool {
        get {
            if let container = avatarView.superview {
                return !container.isHidden
            }
            
            return false
        }
        set {
            avatarView.superview?.isHidden = !newValue
        }
    }
    
    public var sendTitle: String = "Send"
    public var cancelTitle: String = "Cancel"
    
    public var placeholderText: String {
        get { return placeholderLabel.text ?? "" }
        set { placeholderLabel.text = newValue }
    }
    
    private weak var heightConstraint: Constraint?
    private weak var bottomConstraint: Constraint?
    private var baseTextHeight = CGFloat.greatestFiniteMagnitude
    
    private lazy var replyContainer: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = backgroundColor
        view.snp.makeConstraints { $0.height.equalTo(TextToolBar.replyContainerHeight) }
        view.isHidden = true
        return view
    }()
    
    private lazy var replyLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.backgroundColor = .clear
        replyContainer.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalTo(textView)
            make.right.equalTo(textView)
        }
        
        return label
    }()
    
    public var replyText: String? {
        didSet {
            replyLabel.text = replyText
            replyContainer.isHidden = replyText == nil
            updateTextHeightIfNeeded()
        }
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
        backgroundColor = UIColor(white: 0.97, alpha: 1)
        addSubview(stackView)
        stackView.snp.makeConstraints { $0.edges.equalToSuperview() }
        placeholderText = "Leave a message"

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardUpdated(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardUpdated(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    public func addToSuperview(_ view: UIView) {
        view.addSubview(self)
        
        snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width)
            heightConstraint = make.height.equalTo(TextToolBar.textContainerHeight).constraint
            bottomConstraint = make.bottom.equalTo(view).constraint
        }
    }
    
    public func updatePlaceholder() {
        placeholderLabel.isHidden = !textView.text.isEmpty
        DispatchQueue.main.async { self.updateSendButton() }
    }
    
    public func updateSendButton() {
        sendButton.isHidden = !textView.isFirstResponder
        
        if !sendButton.isHidden {
            sendButton.setTitle(textView.text.isEmpty ? cancelTitle : sendTitle, for: .normal)
        }
    }
}

// MARK: - Text View Height

extension TextToolBar {
    /// Update the height of the text view for a big text length.
    public func updateTextHeightIfNeeded() {
        guard heightConstraint != nil  else {
            return
        }
        
        if baseTextHeight == .greatestFiniteMagnitude {
            let text = textView.text
            textView.text = "T"
            baseTextHeight = textViewContentSize.height.rounded()
            textView.text = text
        }
        
        guard textView.text.count > 0 else {
            updateTextHeight(baseTextHeight)
            return
        }
        
        updateTextHeight(textViewContentSize.height.rounded())
    }
    
    private var textViewContentSize: CGSize {
        return textView.sizeThatFits(CGSize(width: textView.frame.width, height: .greatestFiniteMagnitude))
    }
    
    private func updateTextHeight(_ height: CGFloat) {
        var height = min(max(height + (TextToolBar.textContainerHeight - baseTextHeight), TextToolBar.textContainerHeight),
                         TextToolBar.textContainerMaxHeight)
        
        if !replyContainer.isHidden {
            height += TextToolBar.replyContainerHeight
        }
        
        if let heightConstraint = heightConstraint, heightConstraint.layoutConstraints.first?.constant != height {
            heightConstraint.update(offset: height)
            layoutIfNeeded()
        }
    }
}

// MARK: - Text View Delegate

extension TextToolBar: UITextViewDelegate {
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        DispatchQueue.main.async { self.updateSendButton() }
        return true
    }
    
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        updatePlaceholder()
        return true
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        updatePlaceholder()
        updateTextHeightIfNeeded()
    }
}

// MARK: - Keyboard Events

extension TextToolBar {
    @objc func keyboardUpdated(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let value = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            superview != nil else {
                return
        }
        
        let willHide = notification.name == UIResponder.keyboardWillHideNotification
        let offset: CGFloat = willHide ? 0 : -value.cgRectValue.height
        bottomConstraint?.update(offset: offset)
        
        if willHide {
            replyText = nil
        }
        
        layoutIfNeeded()
    }
}
