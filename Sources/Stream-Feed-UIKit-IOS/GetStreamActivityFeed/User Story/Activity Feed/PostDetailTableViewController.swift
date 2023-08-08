//
//  PostDetailTableViewController.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 01/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import SnapKit
import GetStream

public final class PostDetailTableViewController: DetailViewController<Activity> {
    weak var backBtn: UIBarButtonItem? {
        let image = UIImage(named: "backArrow")
        let desiredImage = image
        let back = UIBarButtonItem(image: desiredImage, style: .plain, target: self, action: #selector(backBtnPressed(_:)))
        return back
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        hideBackButtonTitle()
        hideKeyboardWhenTappedAround()
        setupNavigationBar()
        setupUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = UIColor.black
        navigationController?.navigationBar.setCustomTitleFont(font: UIFont(name: "GTWalsheimProBold", size: 18.0)!)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationItem.leftBarButtonItem = backBtn
        navigationItem.title = "Post Details"
    }
    
    public override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    private func setupUI() {
        extendedLayoutIncludesOpaqueBars = true
        view.backgroundColor = .white
    }
    
    @objc private func backBtnPressed(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Table view data source

extension PostDetailTableViewController {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = sectionTitle(in: section) else {
            return nil
        }
        
        let view = UIView(frame: .zero)
        view.backgroundColor = Appearance.Color.lightGray
        
        let label = UILabel(frame: .zero)
        label.textColor = .gray
        label.attributedText = NSAttributedString(string: title.uppercased(), attributes: Appearance.headerTextAttributes())
        view.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.top.bottom.equalToSuperview()
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 || sectionTitle(in: section) == nil ? 0 : 30
    }
}
extension PostDetailTableViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return (navigationController?.viewControllers.count ?? 0) > 1
    }
    
    // This is necessary because without it, subviews of your top controller can
    // cancel out your gesture recognizer on the edge.
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
