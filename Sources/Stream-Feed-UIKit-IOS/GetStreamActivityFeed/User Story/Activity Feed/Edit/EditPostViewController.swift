//
//  EditPostViewController.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 25/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import GetStream
import Nuke

public final class EditPostViewController: UIViewController, BundledStoryboardLoadable {
    public static var storyboardName = "ActivityFeed"
    private static let textViewPlaceholder = NSAttributedString(string: "Share something...")
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    var presenter: EditPostPresenter?
    
    @IBOutlet weak var activityIndicatorBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var galleryStackView: UIStackView!
    @IBOutlet weak var uploadImageStackView: UIStackView!
    @IBOutlet weak var galleryStackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var topMainView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addImageBtn: UIButton!
    @IBOutlet weak var addImageTextBtn: UIButton!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!

    weak var postBtn: UIButton? {
        let btn = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 78, height: 40)))
        btn.backgroundColor = UIColor(red: 95/255, green: 65/255, blue: 224/255, alpha: 1)
        let postButtonTitle = "Post"
        btn.setTitle(postButtonTitle, for: .normal)
        btn.titleLabel?.font = UIFont(name: "GTWalsheimProRegular", size: 16.0)!
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(postBtnPressed(_:)), for: .touchUpInside)
        return btn
    }
    
    weak var backBtn: UIBarButtonItem? {
        let image = UIImage(named: "backArrow")
        let desiredImage = image
        let back = UIBarButtonItem(image: desiredImage, style: .plain, target: self, action: #selector(backBtnPressed(_:)))
        return back
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUserData()
        setupTextView()
        setupTableView()
        setupCollectionView()
        activityIndicatorBarButtonItem.customView = activityIndicator
        hideKeyboardWhenTappedAround()
        keyboardBinding()
        addImageBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addImage)))
        addImageTextBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addImageTextTapped)))
        setupNavigationBarItems()
        topMainView.frame.size.height = tableView.frame.height - galleryStackView.frame.height
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hideHairline()
    }
    
    private func setupNavigationBarItems() {
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: postBtn!), activityIndicatorBarButtonItem]
        navigationItem.leftBarButtonItem = backBtn
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.customView?.alpha = 0.5
        navigationController?.navigationBar.setCustomTitleFont(font: UIFont(name: "GTWalsheimProBold", size: 18.0)!)
    }
    
    @objc private func backBtnPressed(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        dismiss(animated: true)
    }
    
    @objc private func postBtnPressed(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        activityIndicator.startAnimating()
        sender.isEnabled = false
        
        presenter?.save(validatedText()) { [weak self] error in
            guard let self = self else {
                return
            }
            
            self.activityIndicator.stopAnimating()
            
            if let error = error {
               // self.showErrorAlert(error)
            } else {
                self.dismiss(animated: true)
            }
        }
    }
    
    private func keyboardBinding(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            galleryStackViewBottomConstraint.constant -= keyboardSize.height - view.safeAreaInset.bottom
            topMainView.frame.size.height = tableView.frame.height - keyboardSize.height - galleryStackView.frame.height + view.safeAreaInset.bottom
            topMainView.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        galleryStackViewBottomConstraint.constant = 0
        topMainView.frame.size.height = tableView.frame.height - galleryStackView.frame.height + view.safeAreaInset.bottom
        topMainView.layoutIfNeeded()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        collectionView.isHidden = false
    }
    
    @objc func addImage() {
        addImageAction()
    }
    
    @objc func addImageTextTapped() {
        addImageAction()
    }
    
    private func addImageAction() {
            view.endEditing(true)
            pickImage(title: "Add a photo") { [weak self] info, status, _ in
                guard let self else { return }
                if let originalImage = info[.originalImage] as? UIImage {
                    self.handlePickedImage(image: originalImage)
                } else if let editedImage = info[.editedImage] as? UIImage {
                    self.handlePickedImage(image: editedImage)
                } else if status != .authorized {
                    print("❌ Photos authorization status: ", status)
                }
            }
    }
    
    private func handlePickedImage(image: UIImage) {
        self.presenter?.images.insert(image, at: 0)
        self.updateCollectionView()
        self.checkUploadedImageLimit()
    }
    
    private func checkUploadedImageLimit() {
        let maximumLimit = self.presenter?.images.count ?? 0 >= 6
        self.uploadImageStackView.isUserInteractionEnabled = maximumLimit ? false : true
        self.uploadImageStackView.alpha = maximumLimit ? 0.5 : 1.0
    }
    
    private func removeImage(at indexPath: IndexPath) {
        if let presenter = presenter, indexPath.item < presenter.images.count {
            presenter.images.remove(at: indexPath.item)
            updateCollectionView()
        }
    }
    
    @objc func done() {
        view.endEditing(true)
    }
    
    private func setupUserData() {
        userNameLabel.text = User.current?.name
        loadAvatar()
    }
    
    private func loadAvatar() {
        User.current?.loadAvatar { [weak self] image in
            if let image = image, let avatarView = self?.avatarView {
                avatarView.image = image.square(with: avatarView.bounds.width)
            }
        }
    }
    
    private func updateSaveButtonEnabling() {
        guard let presenter = presenter else {
            return
        }
        navigationItem.rightBarButtonItem?.isEnabled = presenter.images.count > 0 || validatedText() != nil
        navigationItem.rightBarButtonItem?.customView?.alpha = presenter.images.count > 0 || validatedText() != nil ? 1 : 0.5
    }
}

// MARK: - Edit Post Viewable

extension EditPostViewController: EditPostViewable {
    
    public func underlineLinks(with dataDetectorURLItems: [DataDetectorURLItem]) {
        textView.attributedText = textView.attributedText.string
            .attributedString { attributedString in
                dataDetectorURLItems.forEach { item in
                    attributedString.addAttributes([.backgroundColor: Appearance.Color.transparentBlue2],
                                                   range: attributedString.string.nsRange(from: item.range))
                }
            }
            .applyedFont(UIFont(name: "GTWalsheimProRegular", size: 14.0)!)
    }
    
    public func updateOpenGraphData() {
        tableView.reloadData()
    }
}

// MARK: - Text View

extension EditPostViewController: UITextViewDelegate {
    
    func setupTextView() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        
        toolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                         UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))]
        textView.inputAccessoryView = toolbar
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.textView.becomeFirstResponder()
        }
    }
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.attributedText.string == EditPostViewController.textViewPlaceholder.string {
            textView.attributedText = NSAttributedString(string: "").applyedFont(UIFont(name: "GTWalsheimProRegular", size: 14.0)!)
        }
        
        return true
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        updateSaveButtonEnabling()
        
        if let text = validatedText() {
           // presenter?.dataDetectorWorker?.match(text)
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        updateSaveButtonEnabling()

        if !(navigationItem.rightBarButtonItem?.isEnabled ?? false) {
            textView.attributedText = EditPostViewController.textViewPlaceholder.applyedFont(UIFont(name: "GTWalsheimProRegular", size: 14.0)!)
        }
    }
    
    private func validatedText() -> String? {
        let text = textView.attributedText.string.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty || text == EditPostViewController.textViewPlaceholder.string ? nil : text
    }
}

// MARK: - Table View

extension EditPostViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.estimatedRowHeight = 116
        tableView.register(UINib(nibName: "OpenGraphTableViewCell", bundle: .module), forCellReuseIdentifier: "OpenGraphTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.ogData == nil ? 0 : 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as OpenGraphTableViewCell
        
        guard let ogData = presenter?.ogData else {
            return cell
        }
        
        cell.update(with: ogData)
        
        return cell
    }
}

// MARK: - Collection View

extension EditPostViewController: UICollectionViewDataSource {
    
    private func setupCollectionView() {
        collectionViewHeightConstraint.constant = 0
        collectionView.register(UINib(nibName: "AddingImageCollectionViewCell", bundle: .module), forCellWithReuseIdentifier: "AddingImageCollectionViewCell")
        collectionView.dataSource = self
    }
    
    private func updateCollectionView() {
        guard let presenter = presenter else {
            return
        }
        collectionViewHeightConstraint.constant = presenter.images.count > 0 ? AddingImageCollectionViewCell.height : 0
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
            self?.collectionView.layoutIfNeeded()
        }
        updateSaveButtonEnabling()
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.images.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as AddingImageCollectionViewCell
        guard let selectedImage = presenter?.images[indexPath.item] else {
            return cell
        }
        cell.setImage(image: selectedImage)
  
        cell.removeButton.addTap { [weak self] _ in
            guard let self else { return }
            self.removeImage(at: indexPath)
            self.checkUploadedImageLimit()
        }
        
        return cell
    }
}
