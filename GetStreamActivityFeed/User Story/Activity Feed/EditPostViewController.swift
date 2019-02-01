//
//  EditPostViewController.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 25/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import Nuke

class EditPostViewController: UIViewController {
    static var storyboardName = "ActivityFeed"
    private static let textViewPlaceholder = NSAttributedString(string: "Share something...")
    
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var activityIndicatorBarButtonItem: UIBarButtonItem!
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    var presenter: EditPostPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Inject presenter.
        if let client = UIApplication.shared.appDelegate.client {
            let presenter = EditPostPresenter(client: client, view: self, activity: nil)
            self.presenter = presenter
        }
        
        loadAvatar()
        setupTextView()
        setupTableView()
        setupCollectionView()
        activityIndicatorBarButtonItem.customView = activityIndicator
    }
    
    @IBAction func close(_ sender: Any) {
        view.endEditing(true)
        dismiss(animated: true)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        activityIndicator.startAnimating()
        sender.isEnabled = false
        
        presenter?.save(validatedText()) { [weak self] error in
            guard let self = self else {
                return
            }
            
            self.saveBarButtonItem.isEnabled = true
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                self.showErrorAlert(error)
            } else {
                self.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func addImage(_ sender: Any) {
        view.endEditing(true)
        
        pickImage(title: "Add a photo") { [weak self] info, status, _ in
            if let image = info[.originalImage] as? UIImage {
                self?.presenter?.images.insert(image, at: 0)
                self?.updateCollectionView()
            } else if status != .authorized {
                print("❌ Photos authorization status: ", status)
            }
        }
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
    
    private func loadAvatar() {
        UIApplication.shared.appDelegate.currentUser?.loadAvatar { [weak self] image in
            if let image = image, let avatarView = self?.avatarView {
                avatarView.image = image.square(with: avatarView.bounds.width)
            }
        }
    }
    
    private func updateSaveButtonEnabling() {
        guard let presenter = presenter else {
            return
        }
        
        saveBarButtonItem.isEnabled = presenter.images.count > 0 || validatedText() != nil
    }
}

// MARK: - Edit Post Viewable

extension EditPostViewController: EditPostViewable {
    
    func underlineLinks(with dataDetectorURLItems: [DataDetectorURLItem]) {
        textView.attributedText = textView.attributedText.string
            .attributedString { attributedString in
                dataDetectorURLItems.forEach { item in
                    attributedString.addAttributes([.backgroundColor: Appearance.Color.transparentBlue2], range: item.range.range)
                }
            }
            .applyFont(textView.font)
    }
    
    func updateOpenGraphData() {
        tableView.reloadData()
    }
}

// MARK: - Text View

extension EditPostViewController: UITextViewDelegate {
    
    func setupTextView() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        
        let imageButton = UIButton(type: .custom)
        imageButton.setImage(.imageIcon, for: .normal)
        imageButton.addTarget(self, action: #selector(addImage(_:)), for: .touchUpInside)
        let imageBarButton = UIBarButtonItem(customView: imageButton)
        
        toolbar.items = [imageBarButton,
                         UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                         UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))]
        
        textView.inputAccessoryView = toolbar
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.attributedText.string == EditPostViewController.textViewPlaceholder.string {
            textView.attributedText = NSAttributedString(string: "").applyFont(textView.font)
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateSaveButtonEnabling()
        
        if let text = validatedText() {
            presenter?.dataDetectorWorker?.match(text)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        updateSaveButtonEnabling()
        
        if !saveBarButtonItem.isEnabled {
            textView.attributedText = EditPostViewController.textViewPlaceholder.applyFont(textView.font)
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
        tableView.register(cellType: OpenGraphTableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.ogData == nil ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        collectionView.register(cellType: AddingImageCollectionViewCell.self)
        collectionView.dataSource = self
    }
    
    private func updateCollectionView() {
        guard let presenter = presenter else {
            return
        }
        
        collectionViewHeightConstraint.constant = presenter.images.count > 0 ? AddingImageCollectionViewCell.height : 0
        collectionView.reloadData()
        updateSaveButtonEnabling()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.images.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as AddingImageCollectionViewCell
        cell.imageView.image = presenter?.images[indexPath.item]
        
        cell.removeButton.addTap { [weak self] _ in
            self?.removeImage(at: indexPath)
        }
        
        return cell
    }
}
