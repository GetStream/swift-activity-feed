//
//  EditProfileViewController.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 16/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

final class EditProfileViewController: UIViewController, BundledStoryboardLoadable {
    
    @IBOutlet weak var avatarView: AvatarView!
    
    @IBOutlet weak var changePhotoView: AvatarView! {
        didSet {
            changePhotoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeAvatar)))
        }
    }
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var activityIndicatorBarButtonItem: UIBarButtonItem!
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    
    var user: User?
    var completion: ((_ user: User) -> Void)?
    var newAvatarImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorBarButtonItem.customView = activityIndicator
        nameTextField.text = user?.name
        loadAvatar()
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        
        guard let user = user else {
            return
        }
        
        sender.isEnabled = false
        activityIndicator.startAnimating()
        user.name = nameTextField.text ?? "<NoName>"
        
        if let newAvatarImage = newAvatarImage {
            user.updateAvatarURL(image: newAvatarImage) { [weak self] error in
                if let error = error {
                    self?.showErrorAlert(error)
                } else {
                    self?.updateUser()
                }
            }
        } else {
            if avatarView.image == nil {
                user.avatarURL = nil
            }
            
            updateUser()
        }
    }
    
    private func updateUser() {
        guard let user = user else {
            return
        }
        
        UIApplication.shared.appDelegate.client?.update(user: user) { [weak self] result in
            guard let self = self else {
                return
            }
            
            if case .success(let user) = result {
                self.completion?(user)
                self.dismiss(animated: true)
            } else if case .failure(let error) = result {
                self.showErrorAlert(error)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK: - Avatar

extension EditProfileViewController {
    
    private func loadAvatar() {
        user?.loadAvatar { [weak self] image in
            self?.avatarView.image = image
        }
    }
    
    @objc func changeAvatar() {
        pickImage(title: "Select your photo", removeTitle: "Remove") { imagePickerInfo, status, removed in
            if let image = imagePickerInfo[.originalImage] as? UIImage {
                let image = image.scale(xTimes: 0.5).square()
                self.avatarView.image = image
                self.newAvatarImage = image
            } else if removed {
                self.avatarView.image = nil
                self.newAvatarImage = nil
            } else if status != .authorized {
                print("❌ Photos authorization status: ", status)
            }
        }
    }
}
