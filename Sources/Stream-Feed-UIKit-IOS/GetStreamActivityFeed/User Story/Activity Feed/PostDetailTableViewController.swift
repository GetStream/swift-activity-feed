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

class PostDetailTableViewController: DetailViewController<Activity> {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        hideBackButtonTitle()
        hideKeyboardWhenTappedAround()
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
