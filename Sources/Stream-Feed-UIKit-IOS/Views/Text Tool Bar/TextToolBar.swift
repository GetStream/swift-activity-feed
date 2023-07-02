//
//  TextToolBar.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 07/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import SnapKit
import GetStream

public final class TextToolBar: UIView {
    
    public static let safeAreaBottom: CGFloat = (UIApplication.shared.delegate?.window as? UIWindow)?.safeAreaInsets.bottom ?? 0
    public static let textContainerHeight: CGFloat = 80
    public static let textContainerMaxHeight: CGFloat = 200
    public static let avatarWidth: CGFloat = 50
    public static let replyContainerHeight: CGFloat = 30
    public static let imagesCollectionHeight: CGFloat = 106
    public static let openGraphPreviewContainerHeight: CGFloat = 116
    
    /// Returns an instance of `TextToolBar`.
    public static func make() -> TextToolBar {
        return TextToolBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: TextToolBar.textContainerHeight))
    }
    
    /// A stack view for containers.
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [openGraphPreviewContainer,
                                                       imagesCollectionView,
                                                       replyContainer,
                                                       textStackView])
        stackView.axis = .vertical
        stackView.backgroundColor = backgroundColor
        
        if TextToolBar.safeAreaBottom > 0, let bottomView = bottomView {
            stackView.addArrangedSubview(bottomView)
        }
        
        return stackView
    }()
    
    private lazy var bottomView: UIView? = {
        let view = UIView(frame: .zero)
        view.backgroundColor = backgroundColor
        view.snp.makeConstraints { $0.height.equalTo(TextToolBar.safeAreaBottom) }
        return view
    }()
    
    // MARK: - Text View Container
    
    private lazy var textStackView: UIStackView = {
        // 1. Avatar View
        let avatarContainer = UIView(frame: .zero)
        avatarContainer.snp.makeConstraints { $0.width.equalTo(TextToolBar.avatarWidth) }
        avatarContainer.addSubview(avatarView)
        avatarContainer.backgroundColor = backgroundColor
        avatarContainer.isHidden = !showAvatar
        
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
        
        let buttonsStackView = UIStackView(arrangedSubviews: [imagePickerButton, sendButton])
        buttonsStackView.axis = .horizontal
        buttonsStackView.isHidden = true
        
        let stackView = UIStackView(arrangedSubviews: [avatarContainer, textViewContainer, buttonsStackView, activityIndicatorView])
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        stackView.axis = .horizontal
        stackView.spacing = 8
        
        return stackView
    }()
    
    /// An `AvatarView`.
    public private(set) lazy var avatarView: AvatarView = {
        let avatarView = AvatarView()
        avatarView.shadowRadius = 6
        avatarView.cornerRadius = TextToolBar.avatarWidth / 2
        avatarView.placeholder = UIImage(named: "user_icon")
        avatarView.tintColor = .gray
        avatarView.alpha = 0.9
        return avatarView
    }()
    
    /// An `UITextView`.
    /// You have to use the `text` property to change the value of the text view.
    public private(set) lazy var textView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.attributedText = NSAttributedString(string: "", attributes: textViewTextAttributes)
        textView.backgroundColor = backgroundColor
        textView.delegate = self
        return textView
    }()
    
    /// The default text view attributes.
    public var textViewTextAttributes: [NSAttributedString.Key: Any] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.1
        return [.font: UIFont(name: "GTWalsheimProRegular", size: 15.0)!, .paragraphStyle: paragraphStyle]
    }()
    
    /// A placeholder label.
    /// You have to use the `placeholderText` property to change the value of the placeholder label.
    public private(set) lazy var placeholderLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .lightGray
        label.backgroundColor = backgroundColor
        textView.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.left.equalTo(textView.textContainer.lineFragmentPadding)
            make.top.equalTo(textView.textContainerInset.top)
            make.right.equalToSuperview()
        }
        
        return label
    }()
    
    /// A send button.
    public private(set) lazy var sendButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle(sendTitle, for: .normal)
        button.setTitleColor(Appearance.Color.gray, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = UIFont(name: "GTWalsheimProMedium", size: 16.0)!
        button.backgroundColor = backgroundColor
        return button
    }()
    
    /// An `UIActivityIndicatorView`.
    public private(set) lazy var activityIndicatorView = UIActivityIndicatorView(style: .medium)
    
    /// The text of the text view.
    public var text: String {
        get { return textView.attributedText.string }
        set {
            textView.attributedText = NSAttributedString(string: newValue)
            updatePlaceholder()
        }
    }
    
    /// An option to show the avatar.
    public var showAvatar: Bool = false {
        didSet { avatarView.superview?.isHidden = !showAvatar }
    }
    
    /// The send button title by default.
    public var sendTitle: String = "Send"
    /// The cancel title of the send button by default.
    public var cancelTitle: String = "Cancel"
    
    /// The placeholder text.
    public var placeholderText: String {
        get { return placeholderLabel.attributedText?.string ?? "" }
        set { placeholderLabel.attributedText = NSAttributedString(string: newValue, attributes: textViewTextAttributes) }
    }
    
    private weak var heightConstraint: Constraint?
    weak var bottomConstraint: Constraint?
    private var baseTextHeight = CGFloat.greatestFiniteMagnitude
    
    // MARK: - Reply Container
    
    private lazy var replyContainer: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = backgroundColor
        view.snp.makeConstraints { $0.height.equalTo(TextToolBar.replyContainerHeight) }
        view.isHidden = true
        return view
    }()
    
    private lazy var replyLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "GTWalsheimProRegular", size: 12.0)!
        label.textColor = .gray
        label.backgroundColor = backgroundColor
        replyContainer.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalTo(textView)
            make.right.equalTo(textView)
        }
        
        return label
    }()
    
    /// A reply text.
    public var replyText: String? {
        didSet {
            replyLabel.text = replyText
            replyContainer.isHidden = replyText == nil
            updateTextHeightIfNeeded()
        }
    }
    
    // MARK: - Open Graph Container
    
    /// Enables the detector of links in the text.
    public var linksDetectorEnabled = false
    /// The color of underline that founded link in the text.
    public var linksHighlightColor: UIColor = Appearance.Color.blue
    /// The Open Graph data of the founded link in the text.
    public internal(set) var openGraphData: OGResponse?
    var detectedURL: URL?
    
    private lazy var dataDetectorWorker: DataDetectorWorker? = linksDetectorEnabled
        ? (try? DataDetectorWorker(types: .link) { [weak self] in self?.updateOpenGraph($0) })
        : nil
    
    lazy var openGraphWorker = OpenGraphWorker() { [weak self] url, openGraphData, error in
        if let self = self {
            if let error = error {
                self.dataDetectorWorker?.match(self.text)
            } else if let openGraphData = openGraphData {
                self.detectedURL = url
                self.openGraphData = openGraphData
                self.updateOpenGraphPreview()
            }
        }
    }
    
    lazy var openGraphPreviewContainer: UIView = {
        let view = UIView(frame: .zero)
        view.isHidden = true
        view.backgroundColor = backgroundColor
        view.addSubview(openGraphPreview)
        view.snp.makeConstraints { $0.height.equalTo(TextToolBar.openGraphPreviewContainerHeight) }
        openGraphPreview.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        return view
    }()
    
    let openGraphPreview = OpenGraphView(frame: .zero)
    
    // MARK: - Images Collection View
    
    /// Picked images.
    public var images: [UIImage] = []
    
    private lazy var imagesCollectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.itemSize = CGSize(width: 90, height: 90)
        collectionViewLayout.minimumLineSpacing = 1
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.isHidden = true
        collectionView.backgroundColor = backgroundColor
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "AddingImageCollectionViewCell", bundle: .module), forCellWithReuseIdentifier: "AddingImageCollectionViewCell")
        collectionView.snp.makeConstraints { $0.height.equalTo(TextToolBar.imagesCollectionHeight) }
        
        return collectionView
    }()
    
    private lazy var imagePickerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(.imageIcon, for: .normal)
        button.isHidden = true
        button.backgroundColor = backgroundColor
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        
        return button
    }()
    
    // MARK: -
    
    private func setup() {
        guard subviews.count == 0 else {
            return
        }
        
        backgroundColor = UIColor(white: 0.97, alpha: 1)
        addSubview(stackView)
        stackView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /// Add the `TextToolBar` to a view container.
    /// Use this method to add `TextToolBar` to the view hierarchy and you no need to do any other layout actions.
    ///
    /// - Parameters:
    ///     - view: the superview.
    ///     - placeholderText: the placeholder text.
    ///     - sendButtonAction: the send button action.
    public func addToSuperview(_ view: UIView,
                               placeholderText: String = "Leave a message",
                               sendButtonAction: UIControl.Action? = nil) {
        setup()
        self.placeholderText = placeholderText
        view.addSubview(self)
        
        snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width)
            heightConstraint = make.height.equalTo(TextToolBar.textContainerHeight + TextToolBar.safeAreaBottom).constraint
            bottomConstraint = make.bottom.equalTo(view).constraint
        }
        
        updateTextHeightIfNeeded()
        
        if let sendButtonAction = sendButtonAction {
            sendButton.addTap(sendButtonAction)
            sendButton.titleLabel?.font = UIFont(name: "GTWalsheimProRegular", size: 14.0)!
        }
    }
    
    /// Check if the content is valid: text is not empty or at least one image was added.
    public var isValidContent: Bool {
        return !textView.attributedText.string.trimmingCharacters(in: .whitespaces).isEmpty || !images.isEmpty
    }
    
    /// Reset states of all child views and clear all added/generated data.
    public func reset() {
        textView.attributedText = NSAttributedString(string: "")
        images = []
        openGraphData = nil
        updateOpenGraphPreview()
        imagesCollectionView.reloadData()
        imagesCollectionView.isHidden = true
        isEnabled = true
        activityIndicatorView.stopAnimating()
        updatePlaceholder()
        updateTextHeightIfNeeded()
    }
    
    /// Toggle `isUserInteractionEnabled` states for all child views.
    public var isEnabled: Bool = true {
        didSet {
            textView.resignFirstResponder()
            textView.isUserInteractionEnabled = isEnabled
            sendButton.isEnabled = isEnabled
            imagePickerButton.isEnabled = isEnabled
            avatarView.isUserInteractionEnabled = isEnabled
            avatarView.alpha = isEnabled ? 1 : 0.5
            imagesCollectionView.isUserInteractionEnabled = isEnabled
            imagesCollectionView.alpha = isEnabled ? 1 : 0.5
            openGraphPreview.isUserInteractionEnabled = isEnabled
            openGraphPreview.alpha = isEnabled ? 1 : 0.5
        }
    }
    
    /// Update the placeholder and send button visibility.
    public func updatePlaceholder() {
        placeholderLabel.isHidden = !textView.attributedText.string.isEmpty
        DispatchQueue.main.async { self.updateSendButton() }
    }
    
    private func updateSendButton() {
        guard let container = sendButton.superview else {
            return
        }
        
        container.isHidden = !textView.isFirstResponder
        container.didMoveToSuperview()
        
        if !container.isHidden {
            sendButton.setTitle(isValidContent ? sendTitle : cancelTitle, for: .normal)
        }
    }
}

// MARK: - Text View Height

extension TextToolBar {
    /// Update the height of the text view for a big text length.
    func updateTextHeightIfNeeded() {
        guard heightConstraint != nil  else {
            return
        }
        
        if baseTextHeight == .greatestFiniteMagnitude {
            let text = textView.attributedText
            textView.attributedText = NSAttributedString(string: "T", attributes: textViewTextAttributes)
            baseTextHeight = textViewContentSize.height.rounded()
            textView.attributedText = text
        }
        
        guard textView.attributedText.length > 0 else {
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
        
        height += textView.isFirstResponder ? 0 : TextToolBar.safeAreaBottom
        
        if !replyContainer.isHidden {
            height += TextToolBar.replyContainerHeight
        }
        
        if !openGraphPreviewContainer.isHidden {
            height += TextToolBar.openGraphPreviewContainerHeight
        }
        
        imagesCollectionView.isHidden = images.count == 0
        
        if !imagesCollectionView.isHidden {
            height += TextToolBar.imagesCollectionHeight
        }
        
        if let heightConstraint = heightConstraint, heightConstraint.layoutConstraints.first?.constant != height {
            heightConstraint.update(offset: height)
            layoutIfNeeded()
        }
    }
}

// MARK: - Text View Delegate

extension TextToolBar: UITextViewDelegate {
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        updateTextHeightIfNeeded()
        updateSendButton()
        bottomView?.isHidden = true
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        updateTextHeightIfNeeded()
        updatePlaceholder()
        bottomView?.isHidden = false
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        updatePlaceholder()
        updateTextHeightIfNeeded()
        
        if !text.isEmpty {
            dataDetectorWorker?.match(text)
        } else {
            openGraphData = nil
            updateOpenGraphPreview()
        }
    }
}

// MARK: - Images Collection View

extension TextToolBar: UICollectionViewDataSource {
    
    /// Enables the image picking with a given view controller.
    /// The view controller will be used to present `UIImagePickerController`.
    public func enableImagePicking(with viewController: UIViewController) {
        imagePickerButton.isHidden = false
        
        imagePickerButton.addTap { [weak self, weak viewController] _ in
            if let self = self, let viewController = viewController {
                viewController.view.endEditing(true)
                self.imagePickerButton.isEnabled = false
                
                viewController.pickImage { info, authorizationStatus, removed in
                    if let image = info[.originalImage] as? UIImage {
                        self.images.insert(image, at: 0)
                        self.imagesCollectionView.reloadData()
                        self.updateTextHeightIfNeeded()
                    } else if authorizationStatus != .authorized {
                        print("❌ Photos authorization status: ", authorizationStatus)
                    }
                    
                    if !self.textView.isFirstResponder {
                        self.textView.becomeFirstResponder()
                    }
                    
                    if authorizationStatus == .authorized || authorizationStatus == .notDetermined {
                        self.imagePickerButton.isEnabled = true
                    }
                }
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as AddingImageCollectionViewCell
        cell.imageView.image = images[indexPath.item]
        
        cell.removeButton.addTap { [weak self] _ in
            if let self = self {
                self.images.remove(at: indexPath.item)
                self.imagesCollectionView.reloadData()
                self.updateTextHeightIfNeeded()
            }
        }
        
        return cell
    }
}
