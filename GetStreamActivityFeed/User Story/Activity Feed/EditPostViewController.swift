//
//  EditPostViewController.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 25/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

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
    
    var activity: Activity?
    
    private lazy var dataDetectorWorker: DataDetectorWorker? = {
        let worker = try? DataDetectorWorker(types: .link) { [weak self] items in
            if let self = self {
                self.updateOpenGraph(items)
                self.underlineLinks(items)
            }
        }
        
        return worker
    }()
    
    private var detectedURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAvatar()
        setupTextView()
        activityIndicatorBarButtonItem.customView = activityIndicator
        collectionViewHeightConstraint.constant = 0
    }
    
    @IBAction func close(_ sender: Any) {
        view.endEditing(true)
        dismiss(animated: true)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        guard let user = UIApplication.shared.appDelegate.currentUser else {
            close(sender)
            return
        }
        
        view.endEditing(true)
        activityIndicator.startAnimating()
        sender.isEnabled = false
        
        let text = textView.attributedText.string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if text.isEmpty || text == EditPostViewController.textViewPlaceholder.string {
            dismiss(animated: true)
            return
        }
        
        let activity = Activity(actor: user, verb: .post, object: .text(text))
        
        user.add(activity: activity) { [weak self] error in
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
        pickImage(title: "Add a photo") { info, status, _ in
            
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
}

// MARK: - Text View

extension EditPostViewController: UITextViewDelegate {
    
    func setupTextView() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        
        toolbar.items = [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addImage(_:))),
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
        let text = validText()
        saveBarButtonItem.isEnabled = text != nil
        
        if let text = text {
            dataDetectorWorker?.match(text)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let text = validText()
        saveBarButtonItem.isEnabled = text != nil
        
        if !saveBarButtonItem.isEnabled {
            textView.attributedText = EditPostViewController.textViewPlaceholder.applyFont(textView.font)
        }
    }
    
    private func validText() -> String? {
        let text = textView.attributedText.string.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty || text == EditPostViewController.textViewPlaceholder.string ? nil : text
    }
    
    private func updateOpenGraph(_ dataDetectorURLItems: [DataDetectorURLItem]) {
        guard let item = dataDetectorURLItems.first else {
            return
        }
        
        if let detectedURL = detectedURL, detectedURL == item.url {
            return
        }
        
        self.detectedURL = item.url
        tableView.reloadData()
    }
    
    private func underlineLinks(_ dataDetectorURLItems: [DataDetectorURLItem]) {
        textView.attributedText = textView.attributedText.string
            .attributedString { attributedString in
                dataDetectorURLItems.forEach { item in
                    attributedString.addAttributes([.backgroundColor: Appearance.Color.transparentYellow2], range: item.range.range)
                }
            }
            .applyFont(textView.font)
    }
}
