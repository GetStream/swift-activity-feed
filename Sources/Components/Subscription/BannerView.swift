//
//  BannerView.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 19/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import SnapKit

/// A banner view protocol to show realtime updates.
public protocol BannerViewProtocol where Self: UIView {
    var textLabel: UILabel { get }
    
    /// Present the banner view in a view controller.
    ///
    /// - Parameter viewController: a view controller where needs to present the banner.
    func present(in viewController: UIViewController)

    /// Present the banner view in a view controller.
    ///
    /// - Parameters:
    ///     - viewController: a view controller where needs to present the banner.
    ///     - forceToAnimate: if it's true, then the banner will be hidden before presenting.
    ///     - timeout: a time interval after that needs to hide the banner.
    func present(in viewController: UIViewController, forceToAnimate: Bool, timeout: DispatchTimeInterval?)
    
    /// Hide the banner.
    ///
    /// - Parameter tableViewController: if the banner was shown in the table view controller,
    ///             then it needs to be cleared from table view header.
    func hide(from tableViewController: UITableViewController?)
}

public final class BannerView: UIView, BannerViewProtocol {
    
    private static let height: CGFloat = 48
    
    private var needsToClearTableViewHeader: Bool = false
    private var dispatchWorkItem: DispatchWorkItem? = nil
    
    public private(set) lazy var textLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .bold)
        addSubview(label)
        backgroundColor = Appearance.Color.blue
        isUserInteractionEnabled = false
        
        label.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(16)
            make.right.bottom.equalToSuperview().offset(-16)
        }
        
        return label
    }()
}

// MARK: - Presenting

extension BannerView {
    
    /// Present the banner view in a view controller.
    ///
    /// - Parameter viewController: a view controller where needs to present the banner.
    public func present(in viewController: UIViewController) {
        present(in: viewController, forceToAnimate: true, timeout: nil)
    }
    
    /// Present the banner view in a view controller.
    ///
    /// - Parameters:
    ///     - viewController: a view controller where needs to present the banner.
    ///     - forceToAnimate: if it's true, then the banner will be hidden before presenting.
    ///     - timeout: a time interval after that needs to hide the banner.
    public func present(in viewController: UIViewController, forceToAnimate: Bool, timeout: DispatchTimeInterval?) {
        dispatchWorkItem?.cancel()
        dispatchWorkItem = nil
        
        guard (superview == nil || forceToAnimate), !(textLabel.text ?? "").isEmpty else {
            return
        }
        
        var timeout = timeout
        
        if superview != nil, forceToAnimate {
            hide(from: viewController as? UITableViewController)
        }
        
        if let navigationController = viewController as? UINavigationController {
            add(to: navigationController.view, topOffset: navigationController.navigationBar.frame.height)
            
        } else if let tableViewController = viewController as? UITableViewController {
            if let navigationController = tableViewController.navigationController {
                if tableViewController.tableView.tableHeaderView == nil {
                    if tableViewController.tableView.contentOffset.y > BannerView.height {
                        present(in: navigationController, forceToAnimate: true, timeout: nil)
                        let navigationControllerBannerTimeout = timeout
                        timeout = nil
                        
                        let dispatchWorkItem = DispatchWorkItem {
                            self.hide()
                            
                            if navigationControllerBannerTimeout == nil {
                                self.present(in: tableViewController)
                            }
                        }
                        
                        self.dispatchWorkItem = dispatchWorkItem
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + (navigationControllerBannerTimeout ?? .seconds(3)),
                                                      execute: dispatchWorkItem)
                    } else {
                        present(in: tableViewController)
                    }
                } else {
                    present(in: navigationController, forceToAnimate: forceToAnimate, timeout: nil)
                }
            } else {
                present(in: tableViewController)
            }
        } else {
            add(to: viewController.view)
        }
        
        show()
        
        if let timeout = timeout {
            let dispatchWorkItem = DispatchWorkItem { self.hide(from: viewController as? UITableViewController) }
            self.dispatchWorkItem = dispatchWorkItem
            DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: dispatchWorkItem)
        }
    }
    
    /// Hide the banner.
    ///
    /// - Parameter tableViewController: if the banner was shown in the table view controller,
    ///             then it needs to be cleared from table view header.
    public func hide(from tableViewController: UITableViewController? = nil) {
        guard superview != nil else {
            return
        }
        
        if needsToClearTableViewHeader {
            tableViewController?.tableView.tableHeaderView = nil
            needsToClearTableViewHeader = false
        }
        
        removeFromSuperview()
    }
    
    private func present(in tableViewController: UITableViewController) {
        let frame = CGRect(x: 0, y: 0, width: tableViewController.view.frame.width, height: BannerView.height)
        let containerView = UIView(frame: frame)
        containerView.isUserInteractionEnabled = false
        containerView.backgroundColor = tableViewController.tableView.backgroundColor
        tableViewController.tableView.tableHeaderView = containerView
        add(to: containerView)
        needsToClearTableViewHeader = true
    }
    
    private func add(to containerView: UIView, topOffset: CGFloat = 0) {
        containerView.addSubview(self)
        
        snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(containerView.safeAreaLayoutGuide.snp.topMargin).offset(topOffset)
        }
    }
    
    private func show() {
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0,
                       options: .curveLinear,
                       animations: {
                        self.alpha = 1
                        self.transform = .identity
        },
                       completion: { _ in
                        self.alpha = 1
                        self.transform = .identity
        })
    }
}
