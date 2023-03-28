//
//  UIViewController+Extensions.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 15/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import SnapKit

// MARK: - Child View Controllers

extension UIViewController {
    
    /// Adds a child view controller to a given container view or to the self view.
    public func add(viewController: UIViewController, to containerView: UIView? = nil) {
        addChild(viewController)
        let containerView: UIView = containerView ?? view
        containerView.addChildViewControllerView(viewController)
        viewController.didMove(toParent: self)
    }
    
    /// Removes a child view controller.
    public func remove(viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
    
    /// Replaces a child view controller with a new one.
    public func replace(viewController: UIViewController, with newViewController: UIViewController) {
        guard let containerView = viewController.view.superview else { return }
        viewController.willMove(toParent: nil)
        addChild(newViewController)
        containerView.addChildViewControllerView(newViewController)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
        newViewController.didMove(toParent: self)
    }
    
    private func addChildViewControllerViewToContainerView(containerView: UIView, childView: UIView) {
        containerView.addSubview(childView)
    }
}

extension UIView {
    fileprivate func addChildViewControllerView(_ childViewController: UIViewController) {
        addSubview(childViewController.view)
        
        childViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - Modal

extension UIViewController {
    /// Return true if the view controller was presented modally.
    public var isModal: Bool {
        return presentingViewController != nil
            || navigationController?.presentingViewController?.presentedViewController === navigationController
            || tabBarController?.presentingViewController is UITabBarController
    }
}

// MARK: - Segue

extension UIViewController {
    /// Performs the segue with an identifier like the view controller class name.
    public func performSegue(show type: UIViewController.Type, sender: Any?) {
        performSegue(withIdentifier: String(describing: type), sender: sender)
    }
}

// MARK: - Show Alert Controller

extension UIViewController {
    func showErrorAlertIfNeeded(_ error: Error?) {
        if let error = error {
            showErrorAlert(error)
        }
    }
    
    func showErrorAlert(_ error: Error, function: String = #function, line: Int = #line) {
        print("❌", function, line, error)
        
        let alertController = UIAlertController(title: "Error",
                                                message: error.localizedDescription,
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true)
    }
}
