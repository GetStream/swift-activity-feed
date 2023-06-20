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
        keyboardBinding()
    }
    
    private func keyboardBinding(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            view.frame.origin.y -= keyboardSize.height
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        guard view.frame.origin.y < -100 else { return }
        view.frame.origin.y = 92
    }
    
    @objc func willResignActive() {
        view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    private func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.setCustomTitleFont(font: UIFont(name: "GTWalsheimProBold", size: 18.0)!)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.leftBarButtonItem = backBtn
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
