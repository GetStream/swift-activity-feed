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
    typealias Completion = (_ view: BannerView) -> Void
    
    var textLabel: UILabel { get }
    
    /// Present the banner view in a view controller.
    ///
    /// - Parameter viewController: a view controller where needs to present the banner.
    @discardableResult
    func show(_ text: String, in viewController: UIViewController) -> Self
    
    /// Hide the banner.
    func hide()
    
    /// Hide the banner after a given time interval.
    ///
    /// - Parameters:
    ///     - timeInterval: an interval of the time after the banner will hide if needed.
    ///     - completion: a block will call when the timer will be triggered to hide the banner.
    func hide(after timeInterval: DispatchTimeInterval, _ completion: Completion?)
    
    /// Add a tap action to the banner.
    func addTap(_ action: @escaping Completion)
    
    /// Remove the tap action from the banner.
    func removeTap()
}

public final class BannerView: UIView, BannerViewProtocol {
    
    private static let height: CGFloat = 48
    
    private var dispatchWorkItem: DispatchWorkItem? = nil
    private var tapGestureRecognizer: UITapGestureRecognizer?
    private var tapAction: Completion?
    
    private weak var presentedInTableView: UITableView?
    
    deinit {
        dispatchWorkItem?.cancel()
        dispatchWorkItem = nil
    }
    
    public static func make() -> BannerView {
        let bannerView = BannerView()
        bannerView.snp.makeConstraints { $0.height.equalTo(BannerView.height) }
        return bannerView
    }
    
    public private(set) lazy var textLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .bold)
        addSubview(label)
        backgroundColor = Appearance.Color.blue
        
        label.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(16)
            make.right.bottom.equalToSuperview().offset(-16)
        }
        
        return label
    }()
    
    public func addTap(_ action: @escaping Completion) {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.numberOfTouchesRequired = 1
        addGestureRecognizer(tapGestureRecognizer)
        self.tapGestureRecognizer = tapGestureRecognizer
        tapAction = action
    }
    
    public func removeTap() {
        tapAction = nil
        
        if let tap = tapGestureRecognizer {
            removeGestureRecognizer(tap)
            tapGestureRecognizer = nil
        }
    }
    
    @objc func tap() {
        if let tapAction = tapAction {
            tapAction(self)
        }
    }
}

// MARK: - Presenting

extension BannerView {
    
    /// Present the banner view in a view controller.
    ///
    /// - Parameter viewController: a view controller where needs to present the banner.
    @discardableResult
    public func show(_ text: String, in viewController: UIViewController) -> BannerView {
        if superview != nil {
            hide()
        }
        
        guard !text.isEmpty else {
            return self
        }
        
        textLabel.text = text
        
        if let navigationController = viewController as? UINavigationController {
            add(to: navigationController.view, topOffset: navigationController.navigationBar.frame.height)
            return self
        }
        
        var tableView: UITableView?
        
        if let tableViewController = viewController as? UITableViewController {
            tableView = tableViewController.tableView
        } else if let subviewTableView = viewController.view.subviews.first as? UITableView {
            tableView = subviewTableView
        }
        
        if let tableView = tableView {
            if tableView.tableHeaderView == nil {
                if tableView.contentOffset.y <= (BannerView.height / 3) {
                    add(to: tableView)
                } else if let navigationController = viewController.navigationController {
                    show(text, in: navigationController, thenIn: tableView)
                } else {
                    add(to: tableView)
                }
                
                return self
                
            } else if let navigationController = viewController.navigationController {
                show(text, in: navigationController)
                return self
            }
        }
        
        add(to: viewController.view)
        
        return self
    }
    
    /// Hide the banner.
    ///
    /// - Parameter animated: hide.
    public func hide() {
        guard superview != nil else {
            return
        }
        
        dispatchWorkItem?.cancel()
        dispatchWorkItem = nil
        removeFromSuperview()
        
        if let presentedInTableView = presentedInTableView {
            presentedInTableView.tableHeaderView = nil
        }
    }
    
    public func hide(after timeInterval: DispatchTimeInterval, _ completion: Completion? = nil) {
        guard superview != nil else {
            return
        }
        
        let dispatchWorkItem = DispatchWorkItem { [weak self] in
            if let self = self {
                self.hide()
                completion?(self)
            }
        }
        
        self.dispatchWorkItem = dispatchWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval, execute: dispatchWorkItem)
    }
    
    private func show(_ text: String, in navigationController: UINavigationController, thenIn tableView: UITableView) {
        show(text, in: navigationController).hide(after: .seconds(3)) { [weak self, weak tableView] _ in
            if let self = self, let tableView = tableView {
                self.add(to: tableView)
            }
        }
    }
    
    private func add(to tableView: UITableView) {
        let frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: BannerView.height)
        let containerView = UIView(frame: frame)
        containerView.backgroundColor = tableView.backgroundColor
        tableView.tableHeaderView = containerView
        add(to: containerView)
        presentedInTableView = tableView
    }
    
    private func add(to containerView: UIView, topOffset: CGFloat = 0) {
        containerView.addSubview(self)
        
        snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(containerView.safeAreaLayoutGuide.snp.topMargin).offset(topOffset)
        }
        
        animate()
    }
    
    private func animate() {
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        
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
