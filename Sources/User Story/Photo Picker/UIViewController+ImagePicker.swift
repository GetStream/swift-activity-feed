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
    public typealias ImagePickerCompletion = (_ imagePickerInfo: [UIImagePickerController.InfoKey : Any],
        _ authorizationStatus: PHAuthorizationStatus) -> Void
    
    public func pickImage(actionTitle: String = "Add",
                          popoverSetup: ((_ alert: UIAlertController) -> Void)? = nil,
                          completion: @escaping ImagePickerCompletion) {
        let alert = UIAlertController(title: "\(actionTitle) a Photo",
                                      message: "Choose a source of a photo",
                                      preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.authorizeImagePicker(sourceType: .photoLibrary, completion)
        }))
        
        alert.addAction(UIAlertAction(title: "Saved Photos Album", style: .default, handler: { _ in
            self.authorizeImagePicker(sourceType: .savedPhotosAlbum, completion)
        }))
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.authorizeImagePicker(sourceType: .camera, completion)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
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
                        completion([:], status)
                    }
                }
            }
        case .restricted, .denied:
            completion([:], status)
        case .authorized:
            showImagePicker(sourceType: sourceType, completion)
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
        completion(info, .authorized)
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        cancellation()
        picker.dismiss(animated: true)
    }
}
