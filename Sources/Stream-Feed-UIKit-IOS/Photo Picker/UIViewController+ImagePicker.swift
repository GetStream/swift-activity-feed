//
//  UIViewController+ImagePicker.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 16/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import Photos.PHPhotoLibrary

extension UIViewController {
    /// A completion block of an image picking.
    ///
    /// - Parameters:
    ///     - imagePickerInfo: the result of the image picking from `UIImagePickerController`.
    ///     - authorizationStatus: the current authorization status. See `PHAuthorizationStatus`.
    ///     - removed: true, if the user select the remove button from the action sheet of the source of the image.
    public typealias ImagePickerCompletion = (_ imagePickerInfo: [UIImagePickerController.InfoKey : Any],
        _ authorizationStatus: PHAuthorizationStatus,
        _ removed: Bool) -> Void
    
    /// Pick an image.
    ///
    /// - Parameters:
    ///     - title: a title of the action sheet to select the source of the image.
    ///     - message: a message of the action sheet to select the source of the image.
    ///     - removeTitle: an optional title to add a button to the action sheet to perform the removing the the image.
    ///     - popoverSetup: an additional setup of `UIAlertController` for proper presenting of it on different devices.
    ///     - completion: a completion block with the picking/removing action result.
    public func pickImage(title: String? = "Add a photo",
                          message: String? = "Select a photo source",
                          removeTitle: String? = nil,
                          popoverSetup: ((_ alert: UIAlertController) -> Void)? = nil,
                          completion: @escaping ImagePickerCompletion) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
                self.authorizeImagePicker(sourceType: .photoLibrary, completion)
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.authorizeImagePicker(sourceType: .camera, completion)
            }))
        }
        
        if let removeTitle = removeTitle {
            alert.addAction(UIAlertAction(title: removeTitle, style: .destructive, handler: { _ in
                completion([:], .notDetermined, true)
            }))
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            completion([:], .notDetermined, false)
        }))
        
        popoverSetup?(alert)
        present(alert, animated: true)
    }
}

// MARK: - Image Picker Authorization
extension UIViewController {
    private func authorizeImagePicker(sourceType: UIImagePickerController.SourceType, _ completion: @escaping ImagePickerCompletion) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            showImagePicker(sourceType: sourceType, completion)
            return
        }
        
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    if status == .authorized {
                        self?.showImagePicker(sourceType: sourceType, completion)
                    } else {
                        completion([:], status, false)
                    }
                }
            }
        case .restricted, .denied:
            completion([:], status, false)
        case .authorized:
            showImagePicker(sourceType: sourceType, completion)
        @unknown default:
            break
        }
    }
}

// MARK: - Image Picker

extension UIViewController {
    private func showImagePicker(sourceType: UIImagePickerController.SourceType, _ completion: @escaping ImagePickerCompletion) {
        let delegateKey = String(ObjectIdentifier(self).hashValue) + "ImagePickerDelegate"
        let imagePickerViewController = UIImagePickerController()
        imagePickerViewController.sourceType = sourceType
        
        let delegate = ImagePickerDelegate(completion) {
            objc_setAssociatedObject(self, delegateKey, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            completion([:], .notDetermined, false)
        }
        
        imagePickerViewController.delegate = delegate
        
        if case .camera = sourceType {
            imagePickerViewController.cameraCaptureMode = .photo
            imagePickerViewController.cameraDevice = .front
            
            if UIImagePickerController.isFlashAvailable(for: .front) {
                imagePickerViewController.cameraFlashMode = .on
            }
        }
        
        objc_setAssociatedObject(self, delegateKey, delegate, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        present(imagePickerViewController, animated: true)
    }
}

// MARK: - Image Picker Delegate

fileprivate final class ImagePickerDelegate: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    typealias Cancel = () -> Void
    let completion: UIViewController.ImagePickerCompletion
    let cancellation: Cancel
    
    init(_ completion: @escaping UIViewController.ImagePickerCompletion, cancellation: @escaping Cancel) {
        self.completion = completion
        self.cancellation = cancellation
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        completion(info, .authorized, false)
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        cancellation()
        picker.dismiss(animated: true)
    }
}
